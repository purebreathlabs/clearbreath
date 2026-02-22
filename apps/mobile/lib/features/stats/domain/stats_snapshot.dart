import 'package:flutter/foundation.dart';

@immutable
class StatsSnapshot {
  StatsSnapshot({
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.minutesThisWeek,
    required this.minutesAllTime,
    required this.sessionsAllTime,
    required Map<String, int> minutesByTechnique,
    required this.longestSessionMinutes,
    required this.favoriteTechniqueId,
    required this.totalBreathsEstimated,
    required this.updatedAt,
  }) : minutesByTechnique = Map.unmodifiable(minutesByTechnique);

  factory StatsSnapshot.empty() {
    return StatsSnapshot(
      currentStreakDays: 0,
      longestStreakDays: 0,
      minutesThisWeek: 0,
      minutesAllTime: 0,
      sessionsAllTime: 0,
      minutesByTechnique: const {},
      longestSessionMinutes: 0,
      favoriteTechniqueId: null,
      totalBreathsEstimated: 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final int currentStreakDays;
  final int longestStreakDays;
  final int minutesThisWeek;
  final int minutesAllTime;
  final int sessionsAllTime;
  final Map<String, int> minutesByTechnique;
  final int longestSessionMinutes;
  final String? favoriteTechniqueId;
  final int totalBreathsEstimated;
  final DateTime updatedAt;
}
