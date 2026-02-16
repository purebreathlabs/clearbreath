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

  void togglePrimaryGoal(PrimaryGoal value) {
    final next = {...state.answers.primaryGoals};
    if (next.contains(value)) {
      if (next.length == 1) {
        return;
      }
      next.remove(value);
    } else {
      next.add(value);
    }

    state = state.copyWith(answers: state.answers.copyWith(primaryGoals: next));
  }

  void togglePracticeWindow(PracticeWindow value) {
    final next = {...state.answers.practiceWindows};

    if (value == PracticeWindow.varies) {
      next
        ..clear()
        ..add(PracticeWindow.varies);
      state = state.copyWith(
        answers: state.answers.copyWith(practiceWindows: next),
      );
      return;
    }

    next.remove(PracticeWindow.varies);
    if (next.contains(value)) {
      if (next.length == 1) {
        next
          ..clear()
          ..add(PracticeWindow.varies);
      } else {
        next.remove(value);
        if (next.isEmpty) {
          next.add(PracticeWindow.varies);
        }
      }
    } else {
      next.add(value);
    }

    state = state.copyWith(
      answers: state.answers.copyWith(practiceWindows: next),
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

  void setReminderTimeMinutes(int minutesSinceMidnight) {
    state = state.copyWith(
      answers: state.answers.copyWith(
        reminderTimeMinutes: minutesSinceMidnight,
      ),
    );
  }

  void setDisplayName(String value) {
    state = state.copyWith(answers: state.answers.copyWith(displayName: value));
  }
}
