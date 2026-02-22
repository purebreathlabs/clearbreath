import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationService {
  Future<bool> requestPermission();

  Future<void> scheduleDailyReminder(TimeOfDay time);
  Future<void> cancelDailyReminder();

  Future<void> scheduleStreakWarning(DateTime scheduledAtLocal);
  Future<void> cancelStreakWarning();

  Future<void> cancelAll();
  Future<void> dispose();
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = Platform.environment.containsKey('FLUTTER_TEST') || kIsWeb
      ? const _NoopNotificationService()
      : _FlutterLocalNotificationService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

class _FlutterLocalNotificationService implements NotificationService {
  static const int _dailyReminderId = 2001;
  static const int _streakWarningId = 2002;

  static const String _channelId = 'life.clearbreath.clearbreath.channel.reminders';
  static const String _channelName = 'Reminders';
  static const String _channelDescription = 'Daily practice reminders and streak warnings';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initFuture;

  Future<void> _ensureInitialized() {
    return _initFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      final location = tz.getLocation(info.identifier);
      tz.setLocalLocation(location);
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings: settings);
  }

  NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: false,
    );
    return const NotificationDetails(android: android, iOS: ios);
  }

  @override
  Future<bool> requestPermission() async {
    if (kIsWeb) {
      return false;
    }

    try {
      await _ensureInitialized();
    } catch (_) {
      return false;
    }

    try {
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await android?.requestNotificationsPermission();
        return granted ?? true;
      }

      if (Platform.isIOS) {
        final ios = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (_) {}

    return true;
  }

  @override
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    if (kIsWeb) {
      return;
    }

    try {
      await _ensureInitialized();
      await cancelDailyReminder();

      final scheduled = _nextDailyInstance(time);

      await _plugin.zonedSchedule(
        id: _dailyReminderId,
        title: 'Daily reminder',
        body: 'Take 2 minutes to breathe today.',
        scheduledDate: scheduled,
        notificationDetails: _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  tz.TZDateTime _nextDailyInstance(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    final today = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return today.isAfter(now) ? today : today.add(const Duration(days: 1));
  }

  @override
  Future<void> cancelDailyReminder() async {
    if (kIsWeb) {
      return;
    }
    try {
      await _ensureInitialized();
      await _plugin.cancel(id: _dailyReminderId);
    } catch (_) {}
  }

  @override
  Future<void> scheduleStreakWarning(DateTime scheduledAtLocal) async {
    if (kIsWeb) {
      return;
    }

    try {
      await _ensureInitialized();
      await cancelStreakWarning();

      final local = scheduledAtLocal.isUtc
          ? scheduledAtLocal.toLocal()
          : scheduledAtLocal;
      final scheduled = tz.TZDateTime.from(local, tz.local);

      await _plugin.zonedSchedule(
        id: _streakWarningId,
        title: 'Streak at risk',
        body: 'Practice 2 minutes before midnight to keep your streak.',
        scheduledDate: scheduled,
        notificationDetails: _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {}
  }

  @override
  Future<void> cancelStreakWarning() async {
    if (kIsWeb) {
      return;
    }
    try {
      await _ensureInitialized();
      await _plugin.cancel(id: _streakWarningId);
    } catch (_) {}
  }

  @override
  Future<void> cancelAll() async {
    if (kIsWeb) {
      return;
    }
    try {
      await _ensureInitialized();
      await _plugin.cancelAll();
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {}
}

class _NoopNotificationService implements NotificationService {
  const _NoopNotificationService();

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> cancelDailyReminder() async {}

  @override
  Future<void> cancelStreakWarning() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleDailyReminder(TimeOfDay time) async {}

  @override
  Future<void> scheduleStreakWarning(DateTime scheduledAtLocal) async {}
}
