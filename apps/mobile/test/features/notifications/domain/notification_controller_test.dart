import 'package:clearbreath/features/notifications/domain/notification_controller.dart';
import 'package:clearbreath/features/notifications/domain/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:clearbreath/features/session/data/session_repository.dart';
import 'package:clearbreath/features/session/domain/local_session.dart';
import 'package:clearbreath/features/settings/data/settings_repository.dart';
import 'package:clearbreath/features/sync/domain/merged_stats_provider.dart';
import 'package:clearbreath/features/stats/domain/stats_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('permission is requested only after first completed session', () async {
    final fake = _FakeNotificationService();

    final container = ProviderContainer(
      overrides: [
        notificationServiceProvider.overrideWithValue(fake),
        notificationNowProvider.overrideWithValue(
          () => DateTime(2026, 2, 22, 10, 0),
        ),
        mergedStatsProvider.overrideWith((ref) async {
          return StatsSnapshot(
            currentStreakDays: 2,
            longestStreakDays: 2,
            practiceDaysAllTime: 0,
            minutesThisWeek: 0,
            minutesAllTime: 0,
            sessionsAllTime: 0,
            minutesByTechnique: const {},
            weeklyMinutesByDay: const [0, 0, 0, 0, 0, 0, 0],
            longestSessionMinutes: 0,
            favoriteTechniqueId: null,
            totalBreathsEstimated: 0,
            updatedAt: DateTime.utc(2026, 2, 22),
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    final keepAlive = container.listen(
      notificationControllerProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(keepAlive.close);

    expect(fake.requestPermissionCalls, equals(0));

    await container
        .read(settingsRepositoryProvider)
        .setReminderTimeMinutes(21 * 60 + 30);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(fake.requestPermissionCalls, equals(0));
    expect(fake.dailySchedules, equals(0));

    final controller = container.read(notificationControllerProvider.notifier);
    await controller.onSessionCompleted();
    expect(
      container.read(notificationControllerProvider).showPermissionPrompt,
      isTrue,
    );
    expect(fake.requestPermissionCalls, equals(0));

    await controller.requestPermissionFromPrompt();
    expect(fake.requestPermissionCalls, equals(1));

    expect(fake.dailySchedules, greaterThanOrEqualTo(1));
    expect(fake.lastDailyTime, const TimeOfDay(hour: 21, minute: 30));

    expect(fake.streakSchedules, greaterThanOrEqualTo(1));
    expect(fake.lastStreakWarningAt, DateTime(2026, 2, 22, 22, 0));
  });

  test('daily reminder reschedules when time changes', () async {
    final fake = _FakeNotificationService();

    final container = ProviderContainer(
      overrides: [
        notificationServiceProvider.overrideWithValue(fake),
        notificationNowProvider.overrideWithValue(
          () => DateTime(2026, 2, 22, 10, 0),
        ),
        mergedStatsProvider.overrideWith((ref) async {
          return StatsSnapshot(
            currentStreakDays: 1,
            longestStreakDays: 1,
            practiceDaysAllTime: 0,
            minutesThisWeek: 0,
            minutesAllTime: 0,
            sessionsAllTime: 0,
            minutesByTechnique: const {},
            weeklyMinutesByDay: const [0, 0, 0, 0, 0, 0, 0],
            longestSessionMinutes: 0,
            favoriteTechniqueId: null,
            totalBreathsEstimated: 0,
            updatedAt: DateTime.utc(2026, 2, 22),
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    final keepAlive = container.listen(
      notificationControllerProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(keepAlive.close);

    final controller = container.read(notificationControllerProvider.notifier);
    await controller.onSessionCompleted();
    await controller.requestPermissionFromPrompt();

    expect(fake.dailySchedules, greaterThanOrEqualTo(1));
    expect(fake.lastDailyTime, const TimeOfDay(hour: 22, minute: 0));

    await container
        .read(settingsRepositoryProvider)
        .setReminderTimeMinutes(7 * 60 + 45);

    await _waitFor(() => fake.dailySchedules >= 2);
    expect(fake.lastDailyTime, const TimeOfDay(hour: 7, minute: 45));
  });

  test('dismiss snoozes prompt for 7 days or 10 sessions', () async {
    final fake = _FakeNotificationService();
    var now = DateTime(2026, 3, 1, 10, 0);

    final container = ProviderContainer(
      overrides: [
        notificationServiceProvider.overrideWithValue(fake),
        notificationNowProvider.overrideWithValue(() => now),
        mergedStatsProvider.overrideWith((ref) async {
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
            updatedAt: DateTime.utc(2026, 3, 1),
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    final keepAlive = container.listen(
      notificationControllerProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(keepAlive.close);

    final controller = container.read(notificationControllerProvider.notifier);
    final repo = container.read(sessionRepositoryProvider);

    await repo.insert(_testSession('s1', now.toUtc()));
    await controller.onSessionCompleted();
    expect(
      container.read(notificationControllerProvider).showPermissionPrompt,
      isTrue,
    );

    await controller.dismissPermissionPrompt();
    expect(
      container.read(notificationControllerProvider).showPermissionPrompt,
      isFalse,
    );
    expect(fake.requestPermissionCalls, equals(0));

    for (var i = 2; i <= 10; i++) {
      await repo.insert(_testSession('s$i', now.toUtc()));
      await controller.onSessionCompleted();
      expect(
        container.read(notificationControllerProvider).showPermissionPrompt,
        isFalse,
      );
    }

    await repo.insert(_testSession('s11', now.toUtc()));
    await controller.onSessionCompleted();
    expect(
      container.read(notificationControllerProvider).showPermissionPrompt,
      isTrue,
    );

    await controller.dismissPermissionPrompt();

    now = DateTime(2026, 3, 8, 10, 0);
    await repo.insert(_testSession('s12', now.toUtc()));
    await controller.onSessionCompleted();
    expect(
      container.read(notificationControllerProvider).showPermissionPrompt,
      isTrue,
    );
  });
}

Future<void> _waitFor(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 1),
}) async {
  final end = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(end)) {
      fail('Timed out waiting for condition.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

LocalSession _testSession(String id, DateTime startedAtUtc) {
  return LocalSession(
    clientSessionId: id,
    techniqueId: 'box',
    presetId: 'default',
    startedAtUtc: startedAtUtc,
    endedAtUtc: startedAtUtc.add(const Duration(minutes: 5)),
    timezoneOffsetMinutes: 0,
    durationSecondsActual: 300,
    breathsCompletedEstimated: 20,
    endedEarly: false,
    syncedToCloud: false,
    createdAt: startedAtUtc,
  );
}

class _FakeNotificationService implements NotificationService {
  int requestPermissionCalls = 0;
  int dailySchedules = 0;
  int streakSchedules = 0;
  int cancelDailyCalls = 0;
  int cancelStreakCalls = 0;

  TimeOfDay? lastDailyTime;
  DateTime? lastStreakWarningAt;

  @override
  Future<bool> requestPermission() async {
    requestPermissionCalls += 1;
    return true;
  }

  @override
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    dailySchedules += 1;
    lastDailyTime = time;
  }

  @override
  Future<void> cancelDailyReminder() async {
    cancelDailyCalls += 1;
  }

  @override
  Future<void> scheduleStreakWarning(DateTime scheduledAtLocal) async {
    streakSchedules += 1;
    lastStreakWarningAt = scheduledAtLocal;
  }

  @override
  Future<void> cancelStreakWarning() async {
    cancelStreakCalls += 1;
  }

  @override
  Future<void> showTest() async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async =>
      [];
}
