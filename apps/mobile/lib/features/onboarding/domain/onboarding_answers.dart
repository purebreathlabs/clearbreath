import 'package:flutter/foundation.dart';

enum ExperienceLevel { beginner, intermediate, advanced }

enum PrimaryGoal { calm, sleep, focus, energy, hrv, spiritual }

enum PracticeWindow { morning, afternoon, evening, varies }

@immutable
class OnboardingAnswers {
  const OnboardingAnswers({
    required this.experienceLevel,
    required this.primaryGoal,
    required this.practiceWindow,
    required this.sessionLengthMinutes,
    required this.hapticsEnabled,
    required this.keepScreenAwake,
    required this.reminderTimeMinutes,
  });

  static const int defaultReminderTimeMinutes = 22 * 60;

  factory OnboardingAnswers.defaults() {
    return const OnboardingAnswers(
      experienceLevel: ExperienceLevel.beginner,
      primaryGoal: PrimaryGoal.calm,
      practiceWindow: PracticeWindow.morning,
      sessionLengthMinutes: 5,
      hapticsEnabled: true,
      keepScreenAwake: true,
      reminderTimeMinutes: defaultReminderTimeMinutes,
    );
  }

  final ExperienceLevel experienceLevel;
  final PrimaryGoal primaryGoal;
  final PracticeWindow practiceWindow;
  final int sessionLengthMinutes;
  final bool hapticsEnabled;
  final bool keepScreenAwake;
  final int reminderTimeMinutes;

  OnboardingAnswers copyWith({
    ExperienceLevel? experienceLevel,
    PrimaryGoal? primaryGoal,
    PracticeWindow? practiceWindow,
    int? sessionLengthMinutes,
    bool? hapticsEnabled,
    bool? keepScreenAwake,
    int? reminderTimeMinutes,
  }) {
    return OnboardingAnswers(
      experienceLevel: experienceLevel ?? this.experienceLevel,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      practiceWindow: practiceWindow ?? this.practiceWindow,
      sessionLengthMinutes: sessionLengthMinutes ?? this.sessionLengthMinutes,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
    );
  }
}
