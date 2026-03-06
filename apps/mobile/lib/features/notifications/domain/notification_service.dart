import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationService {
  Future<bool> requestPermission();

  Future<void> scheduleDailyReminder(TimeOfDay time);
  Future<void> cancelDailyReminder();

  Future<void> scheduleStreakWarning(DateTime scheduledAtLocal);
  Future<void> cancelStreakWarning();

  Future<void> showTest();
  Future<void> cancelAll();
  Future<void> dispose();

  Future<List<PendingNotificationRequest>> getPendingNotifications();
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

  static const String _channelId =
      'life.clearbreath.clearbreath.channel.reminders';
  static const String _channelName = 'Reminders';
  static const String _channelDescription =
      'Daily practice reminders and streak warnings';

  static const String _timezoneCacheKey = 'notification_cached_timezone';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void>? _initFuture;

  Future<void> _ensureInitialized() {
    return _initFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      debugPrint('NotificationService: detected timezone: ${info.identifier}');
      final location = tz.getLocation(info.identifier);
      tz.setLocalLocation(location);
      await _cacheTimezone(info.identifier);
    } catch (e, st) {
      debugPrint('NotificationService: timezone detection failed: $e\n$st');
      final cached = await _getCachedTimezone();
      if (cached != null) {
        debugPrint('NotificationService: using cached timezone: $cached');
        tz.setLocalLocation(tz.getLocation(cached));
      } else {
        debugPrint(
          'NotificationService: WARNING - falling back to UTC, '
          'notifications may fire at wrong time',
        );
        tz.setLocalLocation(tz.UTC);
      }
    }

    const android = AndroidInitializationSettings('ic_notification');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings: settings);
  }

  Future<void> _cacheTimezone(String timezoneId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_timezoneCacheKey, timezoneId);
    } catch (e) {
      debugPrint('NotificationService: failed to cache timezone: $e');
    }
  }

  Future<String?> _getCachedTimezone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_timezoneCacheKey);
    } catch (e) {
      debugPrint('NotificationService: failed to read cached timezone: $e');
      return null;
    }
  }

  NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      icon: 'ic_notification',
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
    } catch (e, st) {
      debugPrint(
        'NotificationService: init failed during requestPermission: $e\n$st',
      );
      return false;
    }

    try {
      if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final granted = await android?.requestNotificationsPermission();
        return granted ?? true;
      }

      if (Platform.isIOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final granted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e, st) {
      debugPrint('NotificationService: requestPermission failed: $e\n$st');
    }

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
      debugPrint(
        'NotificationService: scheduling daily reminder at '
        '${scheduled.toString()} (tz: ${tz.local.name})',
      );

      await _plugin.zonedSchedule(
        id: _dailyReminderId,
        title: 'Daily reminder',
        body: 'Take 2 minutes to breathe today.',
        scheduledDate: scheduled,
        notificationDetails: _details(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e, st) {
      debugPrint('NotificationService: scheduleDailyReminder failed: $e\n$st');
    }
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
    } catch (e, st) {
      debugPrint('NotificationService: cancelDailyReminder failed: $e\n$st');
    }
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

      debugPrint(
        'NotificationService: scheduling streak warning at '
        '${scheduled.toString()} (tz: ${tz.local.name})',
      );

      await _plugin.zonedSchedule(
        id: _streakWarningId,
        title: 'Streak at risk',
        body: 'Practice 2 minutes before midnight to keep your streak.',
        scheduledDate: scheduled,
        notificationDetails: _details(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e, st) {
      debugPrint('NotificationService: scheduleStreakWarning failed: $e\n$st');
    }
  }

  @override
  Future<void> cancelStreakWarning() async {
    if (kIsWeb) {
      return;
    }
    try {
      await _ensureInitialized();
      await _plugin.cancel(id: _streakWarningId);
    } catch (e, st) {
      debugPrint('NotificationService: cancelStreakWarning failed: $e\n$st');
    }
  }

  @override
  Future<void> cancelAll() async {
    if (kIsWeb) {
      return;
    }
    try {
      await _ensureInitialized();
      await _plugin.cancelAll();
    } catch (e, st) {
      debugPrint('NotificationService: cancelAll failed: $e\n$st');
    }
  }

  @override
  Future<void> showTest() async {
    if (kIsWeb) {
      return;
    }
    try {
      await _ensureInitialized();
      await requestPermission();
      await _plugin.show(
        id: 9999,
        title: 'Test notification',
        body: 'If you see the ClearBreath icon, it works!',
        notificationDetails: _details(),
      );
    } catch (e, st) {
      debugPrint('NotificationService: showTest failed: $e\n$st');
    }
  }

  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      await _ensureInitialized();
      return _plugin.pendingNotificationRequests();
    } catch (e, st) {
      debugPrint(
        'NotificationService: getPendingNotifications failed: $e\n$st',
      );
      return [];
    }
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

  @override
  Future<void> showTest() async {}

  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async =>
      [];
}
