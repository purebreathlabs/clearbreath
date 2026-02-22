import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/data/session_repository.dart';
import '../../session/domain/local_session.dart';
import '../data/stats_cache_repository.dart';
import 'stats_snapshot.dart';
import 'streak_calculator.dart';

final localStatsProvider = FutureProvider<StatsSnapshot>((ref) async {
  final sessions = await ref.watch(sessionRepositoryProvider).all();
  final now = DateTime.now().toUtc();
  final offset = DateTime.now().timeZoneOffset.inMinutes;

  final snapshot = computeStats(sessions, now, offset);

  final cache = ref.watch(statsCacheRepositoryProvider);
  try {
    await cache.writeCache(snapshot);
  } catch (_) {}

  return snapshot;
});

StatsSnapshot computeStats(
  List<LocalSession> sessions,
  DateTime now,
  int currentTimezoneOffsetMinutes,
) {
  final nowUtc = now.toUtc();
  final updatedAt = nowUtc;

  var totalSecondsAllTime = 0;
  var totalBreathsEstimated = 0;
  var longestSessionSeconds = 0;

  final secondsByTechnique = <String, int>{};
  final secondsByLocalDay = <DateTime, int>{};

  for (final session in sessions) {
    final seconds = session.durationSecondsActual;
    final safeSeconds = seconds < 0 ? 0 : seconds;

    totalSecondsAllTime += safeSeconds;
    if (safeSeconds > longestSessionSeconds) {
      longestSessionSeconds = safeSeconds;
    }

    final breaths = session.breathsCompletedEstimated;
    if (breaths > 0) {
      totalBreathsEstimated += breaths;
    }

    secondsByTechnique[session.techniqueId] =
        (secondsByTechnique[session.techniqueId] ?? 0) + safeSeconds;

    final dayKey = _localDayKey(
      startedAtUtc: session.startedAtUtc,
      timezoneOffsetMinutes: session.timezoneOffsetMinutes,
    );
    secondsByLocalDay[dayKey] = (secondsByLocalDay[dayKey] ?? 0) + safeSeconds;
  }

  final minutesAllTime = totalSecondsAllTime ~/ 60;
  final sessionsAllTime = sessions.length;
  final longestSessionMinutes = longestSessionSeconds ~/ 60;

  final minutesByTechnique = <String, int>{};
  for (final entry in secondsByTechnique.entries) {
    minutesByTechnique[entry.key] = entry.value ~/ 60;
  }

  final favoriteTechniqueId = _favoriteTechniqueId(secondsByTechnique);

  final minutesByLocalDay = <DateTime, int>{};
  for (final entry in secondsByLocalDay.entries) {
    minutesByLocalDay[entry.key] = entry.value ~/ 60;
  }

  final nowLocal = nowUtc.add(Duration(minutes: currentTimezoneOffsetMinutes));
  final todayKey = DateTime.utc(nowLocal.year, nowLocal.month, nowLocal.day);
  final startOfWeekKey = _startOfWeekKey(todayKey);

  var weekSeconds = 0;
  for (final entry in secondsByLocalDay.entries) {
    final day = entry.key;
    if (day.isBefore(startOfWeekKey) || day.isAfter(todayKey)) {
      continue;
    }
    weekSeconds += entry.value;
  }
  final minutesThisWeek = weekSeconds ~/ 60;

  return StatsSnapshot(
    currentStreakDays: currentStreak(minutesByLocalDay, todayKey),
    longestStreakDays: longestStreak(minutesByLocalDay),
    minutesThisWeek: minutesThisWeek,
    minutesAllTime: minutesAllTime,
    sessionsAllTime: sessionsAllTime,
    minutesByTechnique: minutesByTechnique,
    longestSessionMinutes: longestSessionMinutes,
    favoriteTechniqueId: favoriteTechniqueId,
    totalBreathsEstimated: totalBreathsEstimated,
    updatedAt: updatedAt,
  );
}

DateTime _localDayKey({
  required DateTime startedAtUtc,
  required int timezoneOffsetMinutes,
}) {
  final localStart = startedAtUtc.toUtc().add(
    Duration(minutes: timezoneOffsetMinutes),
  );
  return DateTime.utc(localStart.year, localStart.month, localStart.day);
}

DateTime _startOfWeekKey(DateTime todayKey) {
  final daysSinceMonday = todayKey.weekday - DateTime.monday;
  return todayKey.subtract(Duration(days: daysSinceMonday));
}

String? _favoriteTechniqueId(Map<String, int> secondsByTechnique) {
  String? bestId;
  var bestSeconds = 0;

  for (final entry in secondsByTechnique.entries) {
    final seconds = entry.value;
    if (seconds < 0) {
      continue;
    }
    if (seconds > bestSeconds) {
      bestSeconds = seconds;
      bestId = entry.key;
      continue;
    }
    if (seconds == bestSeconds && seconds > 0 && bestId != null) {
      if (entry.key.compareTo(bestId) < 0) {
        bestId = entry.key;
      }
    }
  }

  return bestSeconds > 0 ? bestId : null;
}
