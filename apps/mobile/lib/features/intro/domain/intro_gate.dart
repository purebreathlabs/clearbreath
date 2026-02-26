import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/intro_repository.dart';
import '../../../shared/providers/app_database_provider.dart';

enum IntroStatus { unknown, incomplete, complete }

final introRepositoryProvider = Provider<IntroRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return IntroRepository(db);
});

final introGateProvider = Provider<IntroGate>((ref) {
  final repository = ref.watch(introRepositoryProvider);
  final gate = IntroGate(repository);
  ref.onDispose(gate.dispose);
  return gate;
});

class IntroGate extends ChangeNotifier {
  IntroGate(
    this._repository, {
    IntroStatus initialStatus = IntroStatus.unknown,
    bool loadOnInit = true,
  }) : _status = initialStatus {
    if (loadOnInit) {
      unawaited(_load());
    }
  }

  final IntroRepository _repository;

  IntroStatus _status;

  IntroStatus get status => _status;

  bool get isComplete => _status == IntroStatus.complete;

  bool get isLoaded => _status != IntroStatus.unknown;

  Future<void> complete() async {
    await _repository.setIntroComplete();
    _setStatus(IntroStatus.complete);
  }

  void reset() {
    _setStatus(IntroStatus.incomplete);
  }

  Future<void> _load() async {
    try {
      final completed = await _repository.isIntroComplete();
      _setStatus(completed ? IntroStatus.complete : IntroStatus.incomplete);
    } catch (_) {
      _setStatus(IntroStatus.incomplete);
    }
  }

  void _setStatus(IntroStatus status) {
    if (_status == status) {
      return;
    }
    _status = status;
    notifyListeners();
  }
}
