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

  static const int totalSteps = 4;

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
    } else {
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
    }

    state = state.copyWith(
      answers: state.answers.copyWith(
        practiceWindows: next,
        reminderTimeMinutes: _defaultReminderTime(next),
      ),
    );
  }

  static int _defaultReminderTime(Set<PracticeWindow> windows) {
    if (windows.length == 1) {
      switch (windows.first) {
        case PracticeWindow.morning:
          return 8 * 60;
        case PracticeWindow.afternoon:
          return 13 * 60;
        case PracticeWindow.evening:
          return 19 * 60;
        case PracticeWindow.varies:
          return 8 * 60;
      }
    }
    return 8 * 60;
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
