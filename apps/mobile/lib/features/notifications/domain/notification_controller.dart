import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/providers/app_database_provider.dart';
import '../../../shared/providers/preferences_provider.dart';
import '../../session/data/session_repository.dart';
import '../../sync/domain/merged_stats_provider.dart';
import 'notification_service.dart';
import 'streak_warning_scheduler.dart';

final notificationNowProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

@immutable
class NotificationState {
  const NotificationState({
    required this.firstSessionCompleted,
    required this.permissionAsked,
    required this.showPermissionPrompt,
  });

  factory NotificationState.fromPreferences(
    Preference? prefs, {
    required bool showPermissionPrompt,
  }) {
    return NotificationState(
      firstSessionCompleted: prefs?.firstSessionCompleted ?? false,
      permissionAsked: prefs?.notificationPermissionAsked ?? false,
      showPermissionPrompt: showPermissionPrompt,
    );
  }

  final bool firstSessionCompleted;
  final bool permissionAsked;
  final bool showPermissionPrompt;
}

final notificationControllerProvider =
    NotifierProvider<NotificationController, NotificationState>(
      NotificationController.new,
    );

class NotificationController extends Notifier<NotificationState> {
  static const int _rowId = 1;
  static const int _snoozeDays = 7;
  static const int _snoozeSessions = 10;

  var _promptPending = false;

  @override
  NotificationState build() {
    ref.listen<AsyncValue<Preference?>>(preferencesProvider, (previous, next) {
      final prevRow = previous?.asData?.value;
      final nextRow = next.asData?.value;
      if (!_shouldResync(prevRow, nextRow)) {
        return;
      }
      unawaited(_syncFromPreferences(nextRow));
    }, fireImmediately: true);

    if (ref.isFirstBuild) {
      unawaited(Future.microtask(_syncFromDb));
    }

    final prefs = ref.watch(preferencesProvider).asData?.value;
    return NotificationState.fromPreferences(
      prefs,
      showPermissionPrompt: _promptPending,
    );
  }

  bool _shouldResync(Preference? previous, Preference? next) {
    if (previous == null && next == null) {
      return false;
    }

    return previous?.reminderEnabled != next?.reminderEnabled ||
        previous?.reminderTimeMinutes != next?.reminderTimeMinutes ||
        previous?.streakWarningEnabled != next?.streakWarningEnabled ||
        previous?.notificationPermissionAsked !=
            next?.notificationPermissionAsked;
  }

  Future<void> onSessionCompleted() async {
    final prefs = await _readPreferences();
    final alreadyCompleted = prefs?.firstSessionCompleted ?? false;
    final permissionAsked = prefs?.notificationPermissionAsked ?? false;

    if (!alreadyCompleted) {
      await _writePreferences(
        PreferencesCompanion(
          id: const Value(_rowId),
          firstSessionCompleted: const Value(true),
        ),
      );
    }

    if (!permissionAsked && !_promptPending) {
      final nowUtc = ref.read(notificationNowProvider)().toUtc();
      final completed = await ref
          .read(sessionRepositoryProvider)
          .completedSessionsCount();
      final snoozeUntilUtc = prefs?.notificationPromptSnoozedUntilUtc;
      final snoozeUntilSessions = prefs?.notificationPromptSnoozedUntilSessions;

      final timeSnoozed =
          snoozeUntilUtc != null && nowUtc.isBefore(snoozeUntilUtc);
      final sessionsSnoozed =
          snoozeUntilSessions != null && completed < snoozeUntilSessions;
      final snoozed = timeSnoozed && sessionsSnoozed;

      if (!snoozed) {
        _promptPending = true;
        state = NotificationState.fromPreferences(
          prefs,
          showPermissionPrompt: _promptPending,
        );
      }
    }

    unawaited(_syncFromDb());
  }

  Future<void> requestPermissionFromPrompt() async {
    if (!_promptPending) {
      return;
    }

    _promptPending = false;
    state = NotificationState.fromPreferences(
      ref.read(preferencesProvider).asData?.value,
      showPermissionPrompt: _promptPending,
    );

    final service = ref.read(notificationServiceProvider);
    try {
      await service.requestPermission();
    } catch (e, st) {
      debugPrint('NotificationController: requestPermission failed: $e\n$st');
    }

    try {
      await _writePreferences(
        PreferencesCompanion(
          id: const Value(_rowId),
          notificationPermissionAsked: const Value(true),
          notificationPromptSnoozedUntilUtc: const Value(null),
          notificationPromptSnoozedUntilSessions: const Value(null),
        ),
      );
    } catch (e, st) {
      debugPrint('NotificationController: writePreferences failed: $e\n$st');
    }

    await _syncFromDb();
  }

  Future<void> dismissPermissionPrompt() async {
    _promptPending = false;
    state = NotificationState.fromPreferences(
      ref.read(preferencesProvider).asData?.value,
      showPermissionPrompt: _promptPending,
    );

    try {
      final nowUtc = ref.read(notificationNowProvider)().toUtc();
      final completed = await ref
          .read(sessionRepositoryProvider)
          .completedSessionsCount();
      await _writePreferences(
        PreferencesCompanion(
          id: const Value(_rowId),
          notificationPromptSnoozedUntilUtc: Value(
            nowUtc.add(const Duration(days: _snoozeDays)),
          ),
          notificationPromptSnoozedUntilSessions: Value(
            completed + _snoozeSessions,
          ),
        ),
      );
    } catch (e, st) {
      debugPrint(
        'NotificationController: dismissPermissionPrompt failed: $e\n$st',
      );
    }
  }

  Future<void> _syncFromDb() async {
    final prefs = await _readPreferences();
    await _syncFromPreferences(prefs);
  }

  Future<Preference?> _readPreferences() async {
    try {
      final db = ref.read(appDatabaseProvider);
      return (db.select(
        db.preferences,
      )..where((row) => row.id.equals(_rowId))).getSingleOrNull();
    } catch (e, st) {
      debugPrint('NotificationController: readPreferences failed: $e\n$st');
      return null;
    }
  }

  Future<void> _writePreferences(PreferencesCompanion companion) async {
    final db = ref.read(appDatabaseProvider);
    await db.into(db.preferences).insertOnConflictUpdate(companion);
  }

  Future<void> _syncFromPreferences(Preference? prefs) async {
    if (prefs == null) {
      return;
    }

    final service = ref.read(notificationServiceProvider);

    if (!prefs.notificationPermissionAsked) {
      return;
    }

    if (prefs.reminderEnabled) {
      final safeMinutes = prefs.reminderTimeMinutes.clamp(0, 23 * 60 + 59);
      final time = TimeOfDay(hour: safeMinutes ~/ 60, minute: safeMinutes % 60);
      await service.scheduleDailyReminder(time);
    } else {
      await service.cancelDailyReminder();
    }

    await _syncStreakWarning(prefs, service: service);
  }

  Future<void> _syncStreakWarning(
    Preference prefs, {
    required NotificationService service,
  }) async {
    if (!prefs.streakWarningEnabled) {
      await service.cancelStreakWarning();
      return;
    }

    var currentStreakDays = 0;
    try {
      final snapshot = await ref.read(mergedStatsProvider.future);
      currentStreakDays = snapshot.currentStreakDays;
    } catch (e, st) {
      debugPrint('NotificationController: failed to read streak: $e\n$st');
    }

    final hasQualifiedToday = await _hasQualifyingSessionToday();
    final now = ref.read(notificationNowProvider)();
    final next = nextStreakWarningTime(
      currentStreakDays,
      hasQualifiedToday,
      now,
    );

    if (next == null) {
      await service.cancelStreakWarning();
      return;
    }

    await service.scheduleStreakWarning(next);
  }

  Future<bool> _hasQualifyingSessionToday() async {
    try {
      final minutesByDay = await ref
          .read(sessionRepositoryProvider)
          .minutesByLocalDay();

      final now = ref.read(notificationNowProvider)();
      final nowUtc = now.toUtc();
      final offsetMinutes = now.timeZoneOffset.inMinutes;
      final nowLocal = nowUtc.add(Duration(minutes: offsetMinutes));
      final todayKey = DateTime.utc(
        nowLocal.year,
        nowLocal.month,
        nowLocal.day,
      );

      final minutes = minutesByDay[todayKey] ?? 0;
      return minutes >= 2;
    } catch (e, st) {
      debugPrint(
        'NotificationController: _hasQualifyingSessionToday failed: $e\n$st',
      );
      return false;
    }
  }
}
