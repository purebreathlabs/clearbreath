import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/onboarding_repository.dart';
import 'onboarding_answers.dart';
import '../../../shared/providers/app_database_provider.dart';

enum OnboardingStatus { unknown, incomplete, complete }

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return OnboardingRepository(db);
});

final onboardingGateProvider = Provider<OnboardingGate>((ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  final gate = OnboardingGate(repository);
  ref.onDispose(gate.dispose);
  return gate;
});

class OnboardingGate extends ChangeNotifier {
  OnboardingGate(
    this._repository, {
    OnboardingStatus initialStatus = OnboardingStatus.unknown,
    bool loadOnInit = true,
  }) : _status = initialStatus {
    if (loadOnInit) {
      unawaited(_load());
    }
  }

  final OnboardingRepository _repository;

  OnboardingStatus _status;

  OnboardingStatus get status => _status;

  bool get isComplete => _status == OnboardingStatus.complete;

  bool get isLoaded => _status != OnboardingStatus.unknown;

  Future<void> complete(OnboardingAnswers answers) async {
    await _repository.setOnboardingComplete(answers);
    _setStatus(OnboardingStatus.complete);
  }

  Future<void> _load() async {
    try {
      final completed = await _repository.isOnboardingComplete();
      _setStatus(
        completed ? OnboardingStatus.complete : OnboardingStatus.incomplete,
      );
    } catch (_) {
      _setStatus(OnboardingStatus.incomplete);
    }
  }

  void _setStatus(OnboardingStatus status) {
    if (_status == status) {
      return;
    }
    _status = status;
    notifyListeners();
  }
}
