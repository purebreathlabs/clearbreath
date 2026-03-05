import 'json_parsing.dart';

class StatsSnapshot {
  const StatsSnapshot({
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.practiceDaysAllTime,
    required this.minutesThisWeek,
    required this.minutesAllTime,
    required this.sessionsAllTime,
    required this.minutesByTechnique,
    required this.weeklyMinutesByDay,
    required this.updatedAtUtc,
    required this.totalXp,
    required this.currentLevel,
  });

  factory StatsSnapshot.fromJson(JsonMap json) {
    return StatsSnapshot(
      currentStreakDays: readInt(json, 'current_streak_days'),
      longestStreakDays: readInt(json, 'longest_streak_days'),
      practiceDaysAllTime: readIntOr(json, 'practice_days_all_time', 0),
      minutesThisWeek: readInt(json, 'minutes_this_week'),
      minutesAllTime: readInt(json, 'minutes_all_time'),
      sessionsAllTime: readInt(json, 'sessions_all_time'),
      minutesByTechnique: readStringIntMap(json, 'minutes_by_technique'),
      weeklyMinutesByDay: json['weekly_minutes_by_day'] == null
          ? const []
          : readIntList(json, 'weekly_minutes_by_day'),
      updatedAtUtc: readDateTimeUtc(json, 'updated_at_utc'),
      totalXp: readInt(json, 'total_xp'),
      currentLevel: readInt(json, 'current_level'),
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
  final DateTime updatedAtUtc;
  final int totalXp;
  final int currentLevel;
}

class WeeklyBreakdown {
  const WeeklyBreakdown({
    required this.weekOffset,
    required this.weekStartLocal,
    required this.weeklyMinutesByDay,
    required this.updatedAtUtc,
  });

  factory WeeklyBreakdown.fromJson(JsonMap json) {
    return WeeklyBreakdown(
      weekOffset: readInt(json, 'week_offset'),
      weekStartLocal: readString(json, 'week_start_local'),
      weeklyMinutesByDay: readIntList(json, 'weekly_minutes_by_day'),
      updatedAtUtc: readDateTimeUtc(json, 'updated_at_utc'),
    );
  }

  final int weekOffset;
  final String weekStartLocal;
  final List<int> weeklyMinutesByDay;
  final DateTime updatedAtUtc;
}
