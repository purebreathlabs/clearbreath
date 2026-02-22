import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/domain/onboarding_answers.dart';
import '../../onboarding/domain/onboarding_answers_provider.dart';

final activeGoalProvider =
    NotifierProvider<ActiveGoalController, Set<PrimaryGoal>>(
      ActiveGoalController.new,
    );

class ActiveGoalController extends Notifier<Set<PrimaryGoal>> {
  var _loaded = false;
  var _userOverridden = false;

  @override
  Set<PrimaryGoal> build() {
    if (!_loaded) {
      _loaded = true;
      unawaited(_loadFromOnboarding());
    }
    return const {PrimaryGoal.calm};
  }

  void select(PrimaryGoal goal) {
    _userOverridden = true;
    state = {goal};
  }

  Future<void> _loadFromOnboarding() async {
    try {
      final answers = await ref.read(onboardingAnswersProvider.future);
      if (_userOverridden) {
        return;
      }
      state = _sanitize(answers.primaryGoals);
    } catch (_) {}
  }

  Set<PrimaryGoal> _sanitize(Set<PrimaryGoal> goals) {
    for (final goal in PrimaryGoal.values) {
      if (goals.contains(goal)) {
        return {goal};
      }
    }
    return const {PrimaryGoal.calm};
  }
}
