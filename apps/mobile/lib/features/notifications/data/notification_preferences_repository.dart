import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/network/api_client.dart';
import '../../auth/data/device_id_store.dart';
import '../../auth/domain/auth_state_provider.dart';

final notificationPreferencesRepositoryProvider =
    Provider<NotificationPreferencesRepository>((ref) {
      return NotificationPreferencesRepository(ref);
    });

class NotificationPreferencesRepository {
  NotificationPreferencesRepository(this._ref);

  final Ref _ref;

  Future<void> syncToBackend({
    required bool reminderEnabled,
    required int reminderTimeMinutes,
    required bool streakWarningEnabled,
  }) async {
    try {
      final deviceId = await _ref.read(deviceIdProvider.future);
      final platform = Platform.isIOS ? 'ios' : 'android';

      String timezoneIana = 'UTC';
      int timezoneOffsetMinutes = 0;
      try {
        final tzInfo = await FlutterTimezone.getLocalTimezone();
        timezoneIana = tzInfo.identifier;
        timezoneOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
      } catch (_) {}

      String appVersion = '';
      String buildNumber = '';
      try {
        final info = await PackageInfo.fromPlatform();
        appVersion = info.version;
        buildNumber = info.buildNumber;
      } catch (_) {}

      final body = {
        'device_id': deviceId,
        'platform': platform,
        'fcm_token': '_pending',
        'permission_status': 'not_determined',
        'reminder_enabled': reminderEnabled,
        'reminder_time_minutes': reminderTimeMinutes,
        'streak_warning_enabled': streakWarningEnabled,
        'timezone_iana': timezoneIana,
        'timezone_offset_minutes': timezoneOffsetMinutes,
        'app_version': appVersion,
        'build_number': buildNumber,
        'locale': Platform.localeName,
      };

      final authState = _ref.read(authStateProvider);
      final Dio dio;
      final String endpoint;

      if (authState.isSignedIn) {
        dio = _ref.read(apiClientProvider);
        endpoint = '/v1/me/notifications/installations';
      } else {
        dio = _ref.read(rawApiClientProvider);
        endpoint = '/v1/notifications/installations';
      }

      await dio.put(endpoint, data: body);
      debugPrint('NotificationPreferencesRepository: synced to backend');
    } catch (e) {
      debugPrint('NotificationPreferencesRepository: sync failed: $e');
    }
  }
}
