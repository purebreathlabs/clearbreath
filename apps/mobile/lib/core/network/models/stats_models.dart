import 'json_parsing.dart';

class StatsSnapshot {
  const StatsSnapshot({
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.minutesThisWeek,
    required this.minutesAllTime,
    required this.sessionsAllTime,
    required this.minutesByTechnique,
    required this.updatedAtUtc,
  });

  factory StatsSnapshot.fromJson(JsonMap json) {
    return StatsSnapshot(
      currentStreakDays: readInt(json, 'current_streak_days'),
      longestStreakDays: readInt(json, 'longest_streak_days'),
      minutesThisWeek: readInt(json, 'minutes_this_week'),
      minutesAllTime: readInt(json, 'minutes_all_time'),
      sessionsAllTime: readInt(json, 'sessions_all_time'),
      minutesByTechnique: readStringIntMap(json, 'minutes_by_technique'),
      updatedAtUtc: readDateTimeUtc(json, 'updated_at_utc'),
    );
  }

  final int currentStreakDays;
  final int longestStreakDays;
  final int minutesThisWeek;
  final int minutesAllTime;
  final int sessionsAllTime;
  final Map<String, int> minutesByTechnique;
  final DateTime updatedAtUtc;
}

