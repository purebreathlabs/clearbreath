import 'package:clearbreath/features/session/domain/local_session.dart';
import 'package:clearbreath/features/stats/domain/stats_engine.dart';
import 'package:clearbreath/features/xp/domain/xp_engine.dart' as xp;
import 'package:flutter_test/flutter_test.dart';

void main() {
  LocalSession buildSession({
    required String id,
    required String techniqueId,
    required DateTime startedAtUtc,
    required int timezoneOffsetMinutes,
    required int durationSecondsActual,
    required int breathsCompletedEstimated,
  }) {
    final endedAtUtc = startedAtUtc.toUtc().add(
      Duration(seconds: durationSecondsActual),
    );
    return LocalSession(
      clientSessionId: id,
      techniqueId: techniqueId,
      presetId: 'beginner',
      startedAtUtc: startedAtUtc.toUtc(),
      endedAtUtc: endedAtUtc,
      timezoneOffsetMinutes: timezoneOffsetMinutes,
      durationSecondsActual: durationSecondsActual,
      breathsCompletedEstimated: breathsCompletedEstimated,
      endedEarly: false,
      syncedToCloud: false,
      createdAt: endedAtUtc,
    );
  }

  test('computes all-time totals and aggregations', () {
    final sessions = [
      buildSession(
        id: 's1',
        techniqueId: 'box',
        startedAtUtc: DateTime.utc(2026, 2, 21, 10),
        timezoneOffsetMinutes: 0,
        durationSecondsActual: 300,
        breathsCompletedEstimated: 10,
      ),
      buildSession(
        id: 's2',
        techniqueId: 'box',
        startedAtUtc: DateTime.utc(2026, 2, 22, 10),
        timezoneOffsetMinutes: 0,
        durationSecondsActual: 120,
        breathsCompletedEstimated: 5,
      ),
      buildSession(
        id: 's3',
        techniqueId: 'four_seven_eight',
        startedAtUtc: DateTime.utc(2026, 2, 22, 11),
        timezoneOffsetMinutes: 0,
        durationSecondsActual: 600,
        breathsCompletedEstimated: 20,
      ),
    ];

    final snapshot = computeStats(sessions, DateTime.utc(2026, 2, 25, 12), 0);

    expect(snapshot.sessionsAllTime, equals(3));
    expect(snapshot.minutesAllTime, equals(17));
    expect(snapshot.longestSessionMinutes, equals(10));
    expect(snapshot.totalBreathsEstimated, equals(35));
    expect(snapshot.minutesByTechnique['box'], equals(7));
    expect(snapshot.minutesByTechnique['four_seven_eight'], equals(10));
    expect(snapshot.favoriteTechniqueId, equals('four_seven_eight'));
    expect(snapshot.totalXP, equals(199));
    expect(snapshot.currentLevel, equals(xp.levelFromTotalXP(199)));
  });

  test('practice XP does not depend on current streak display', () {
    final sessions = [
      buildSession(
        id: 's1',
        techniqueId: 'box',
        startedAtUtc: DateTime.utc(2026, 2, 21, 10),
        timezoneOffsetMinutes: 0,
        durationSecondsActual: 300,
        breathsCompletedEstimated: 10,
      ),
      buildSession(
        id: 's2',
        techniqueId: 'box',
        startedAtUtc: DateTime.utc(2026, 2, 22, 10),
        timezoneOffsetMinutes: 0,
        durationSecondsActual: 120,
        breathsCompletedEstimated: 5,
      ),
      buildSession(
        id: 's3',
        techniqueId: 'four_seven_eight',
        startedAtUtc: DateTime.utc(2026, 2, 22, 11),
        timezoneOffsetMinutes: 0,
        durationSecondsActual: 600,
        breathsCompletedEstimated: 20,
      ),
    ];

    final onStreak = computeStats(sessions, DateTime.utc(2026, 2, 22, 12), 0);
    final afterGap = computeStats(sessions, DateTime.utc(2026, 2, 25, 12), 0);

    expect(onStreak.currentStreakDays, equals(2));
    expect(afterGap.currentStreakDays, equals(0));
    expect(onStreak.totalXP, equals(199));
    expect(afterGap.totalXP, equals(199));
  });

  test('computes weekly minutes with Monday start', () {
    final now = DateTime.utc(2026, 2, 25, 12);
    final todayKey = DateTime.utc(now.year, now.month, now.day);
    final startOfWeekKey = todayKey.subtract(
      Duration(days: todayKey.weekday - DateTime.monday),
    );

    final sessions = [
      buildSession(
        id: 'sun',
        techniqueId: 'box',
        startedAtUtc: startOfWeekKey
            .subtract(const Duration(days: 1))
            .add(const Duration(hours: 10)),
        timezoneOffsetMinutes: 0,
        durationSecondsActual: 600,
        breathsCompletedEstimated: 1,
      ),
      buildSession(
        id: 'mon',
        techniqueId: 'box',
        startedAtUtc: startOfWeekKey.add(const Duration(hours: 10)),
        timezoneOffsetMinutes: 0,
        durationSecondsActual: 300,
        breathsCompletedEstimated: 1,
      ),
      buildSession(
        id: 'wed',
        techniqueId: 'box',
        startedAtUtc: todayKey.add(const Duration(hours: 10)),
        timezoneOffsetMinutes: 0,
        durationSecondsActual: 120,
        breathsCompletedEstimated: 1,
      ),
    ];

    final snapshot = computeStats(sessions, now, 0);

    expect(snapshot.minutesThisWeek, equals(7));
  });

  test('caps practice XP per local day', () {
    final sessions = List.generate(
      7,
      (i) => buildSession(
        id: 's$i',
        techniqueId: 'box',
        startedAtUtc: DateTime.utc(2026, 2, 22, 10, i),
        timezoneOffsetMinutes: 0,
        durationSecondsActual: 600,
        breathsCompletedEstimated: 1,
      ),
    );

    final snapshot = computeStats(sessions, DateTime.utc(2026, 2, 25, 12), 0);

    expect(snapshot.totalXP, equals(xp.dailyPracticeXPCap));
  });

  test('favorite technique is deterministic on ties', () {
    final sessions = [
      buildSession(
        id: 'a1',
        techniqueId: 'alpha',
        startedAtUtc: DateTime.utc(2026, 2, 21, 10),
        timezoneOffsetMinutes: 0,
        durationSecondsActual: 300,
        breathsCompletedEstimated: 1,
      ),
      buildSession(
        id: 'b1',
        techniqueId: 'bravo',
        startedAtUtc: DateTime.utc(2026, 2, 21, 11),
        timezoneOffsetMinutes: 0,
        durationSecondsActual: 300,
        breathsCompletedEstimated: 1,
      ),
    ];

    final snapshot = computeStats(sessions, DateTime.utc(2026, 2, 25, 12), 0);

    expect(snapshot.favoriteTechniqueId, equals('alpha'));
  });

  test('assigns local day using session timezone offset', () {
    final sessions = [
      buildSession(
        id: 'late',
        techniqueId: 'box',
        startedAtUtc: DateTime.utc(2026, 2, 20, 23, 30),
        timezoneOffsetMinutes: 60,
        durationSecondsActual: 120,
        breathsCompletedEstimated: 1,
      ),
    ];

    final snapshot = computeStats(sessions, DateTime.utc(2026, 2, 22, 1), 60);

    expect(snapshot.currentStreakDays, equals(1));
    expect(snapshot.longestStreakDays, equals(1));
    expect(snapshot.totalXP, equals(22));
    expect(snapshot.currentLevel, equals(1));
  });
}
