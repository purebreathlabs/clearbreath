import 'package:flutter/foundation.dart';

@immutable
class StatsSnapshot {
  StatsSnapshot({
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.practiceDaysAllTime,
    required this.minutesThisWeek,
    required this.minutesAllTime,
    required this.sessionsAllTime,
    required Map<String, int> minutesByTechnique,
    required List<int> weeklyMinutesByDay,
    required this.longestSessionMinutes,
    required this.favoriteTechniqueId,
    required this.totalBreathsEstimated,
    required this.updatedAt,
    this.totalXP = 0,
    this.currentLevel = 0,
  }) : minutesByTechnique = Map.unmodifiable(minutesByTechnique),
       weeklyMinutesByDay = List.unmodifiable(weeklyMinutesByDay);

  factory StatsSnapshot.empty() {
    return StatsSnapshot(
      currentStreakDays: 0,
      longestStreakDays: 0,
      practiceDaysAllTime: 0,
      minutesThisWeek: 0,
      minutesAllTime: 0,
      sessionsAllTime: 0,
      minutesByTechnique: const {},
      weeklyMinutesByDay: const [0, 0, 0, 0, 0, 0, 0],
      longestSessionMinutes: 0,
      favoriteTechniqueId: null,
      totalBreathsEstimated: 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final int currentStreakDays;
  final int longestStreakDays;
  final int practiceDaysAllTime;
  final int minutesThisWeek;
  final int minutesAllTime;
  final int sessionsAllTime;
  final Map<String, int> minutesByTechnique;
  final List<int> weeklyMinutesByDay;
  final int longestSessionMinutes;
  final String? favoriteTechniqueId;
  final int totalBreathsEstimated;
  final DateTime updatedAt;
  final int totalXP;
  final int currentLevel;
}
