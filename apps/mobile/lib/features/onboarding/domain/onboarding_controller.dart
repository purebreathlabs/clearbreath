import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_answers.dart';

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );

@immutable
class OnboardingState {
  const OnboardingState({required this.stepIndex, required this.answers});

  static const int totalSteps = 7;

  final int stepIndex;
  final OnboardingAnswers answers;

  bool get canGoBack => stepIndex > 0;
  bool get isLastStep => stepIndex == totalSteps - 1;
  double get progress => (stepIndex + 1) / totalSteps;

  OnboardingState copyWith({int? stepIndex, OnboardingAnswers? answers}) {
    return OnboardingState(
      stepIndex: stepIndex ?? this.stepIndex,
      answers: answers ?? this.answers,
    );
  }
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return OnboardingState(stepIndex: 0, answers: OnboardingAnswers.defaults());
  }

  void back() {
    if (state.stepIndex == 0) {
      return;
    }
    state = state.copyWith(stepIndex: state.stepIndex - 1);
  }

  void next() {
    if (state.stepIndex >= OnboardingState.totalSteps - 1) {
      return;
    }
    state = state.copyWith(stepIndex: state.stepIndex + 1);
  }

  void setExperienceLevel(ExperienceLevel value) {
    state = state.copyWith(
      answers: state.answers.copyWith(experienceLevel: value),
    );
  }

  void setPrimaryGoal(PrimaryGoal value) {
    state = state.copyWith(answers: state.answers.copyWith(primaryGoal: value));
  }

  void setPracticeWindow(PracticeWindow value) {
    state = state.copyWith(
      answers: state.answers.copyWith(practiceWindow: value),
    );
  }

  void setSessionLengthMinutes(int minutes) {
    state = state.copyWith(
      answers: state.answers.copyWith(sessionLengthMinutes: minutes),
    );
  }

  void setHapticsEnabled(bool enabled) {
    state = state.copyWith(
      answers: state.answers.copyWith(hapticsEnabled: enabled),
    );
  }

  void setKeepScreenAwake(bool enabled) {
    state = state.copyWith(
      answers: state.answers.copyWith(keepScreenAwake: enabled),
    );
  }

  void setReminderTimeMinutes(int minutesSinceMidnight) {
    state = state.copyWith(
      answers: state.answers.copyWith(
        reminderTimeMinutes: minutesSinceMidnight,
      ),
    );
  }
}
