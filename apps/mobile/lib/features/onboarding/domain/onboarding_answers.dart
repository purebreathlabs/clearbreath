import 'package:flutter/foundation.dart';

enum ExperienceLevel { beginner, intermediate, advanced }

enum PrimaryGoal { calm, sleep, focus, energy, hrv, spiritual }

enum PracticeWindow { morning, afternoon, evening, varies }

@immutable
class OnboardingAnswers {
  OnboardingAnswers({
    required this.experienceLevel,
    required Set<PrimaryGoal> primaryGoals,
    required Set<PracticeWindow> practiceWindows,
    required this.sessionLengthMinutes,
    required this.hapticsEnabled,
    required this.reminderTimeMinutes,
    required this.displayName,
  }) : primaryGoals = Set.unmodifiable(primaryGoals),
       practiceWindows = Set.unmodifiable(practiceWindows);

  static const int defaultReminderTimeMinutes = 22 * 60;

  factory OnboardingAnswers.defaults() {
    return OnboardingAnswers(
      experienceLevel: ExperienceLevel.beginner,
      primaryGoals: {PrimaryGoal.calm},
      practiceWindows: {PracticeWindow.varies},
      sessionLengthMinutes: 5,
      hapticsEnabled: true,
      reminderTimeMinutes: defaultReminderTimeMinutes,
      displayName: '',
    );
  }

  final ExperienceLevel experienceLevel;
  final Set<PrimaryGoal> primaryGoals;
  final Set<PracticeWindow> practiceWindows;
  final int sessionLengthMinutes;
  final bool hapticsEnabled;
  final int reminderTimeMinutes;
  final String displayName;

  OnboardingAnswers copyWith({
    ExperienceLevel? experienceLevel,
    Set<PrimaryGoal>? primaryGoals,
    Set<PracticeWindow>? practiceWindows,
    int? sessionLengthMinutes,
    bool? hapticsEnabled,
    int? reminderTimeMinutes,
    String? displayName,
  }) {
    return OnboardingAnswers(
      experienceLevel: experienceLevel ?? this.experienceLevel,
      primaryGoals: primaryGoals ?? this.primaryGoals,
      practiceWindows: practiceWindows ?? this.practiceWindows,
      sessionLengthMinutes: sessionLengthMinutes ?? this.sessionLengthMinutes,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
      displayName: displayName ?? this.displayName,
    );
  }
}
