import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../auth/data/device_id_store.dart';
import '../../auth/domain/auth_state_provider.dart';

final fcmTokenServiceProvider = Provider<FCMTokenService>((ref) {
  return FCMTokenService(ref);
});

class FCMTokenService {
  FCMTokenService(this._ref);

  final Ref _ref;

  static const _lastTokenKey = 'fcm_last_registered_token';
  String? _currentToken;
  StreamSubscription<String>? _tokenRefreshSub;

  Future<void> initialize() async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.setAutoInitEnabled(true);

      if (Platform.isIOS) {
        String? apnsToken;
        for (var i = 0; i < 3; i++) {
          apnsToken = await messaging.getAPNSToken();
          if (apnsToken != null) break;
          await Future.delayed(const Duration(seconds: 1));
        }
        if (apnsToken == null) {
          debugPrint('FCMTokenService: APNs token not available, skipping');
          return;
        }
      }

      final token = await messaging.getToken();
      if (token == null) {
        debugPrint('FCMTokenService: FCM token is null');
        return;
      }

      await _registerIfChanged(token);

      _tokenRefreshSub?.cancel();
      _tokenRefreshSub = messaging.onTokenRefresh.listen((newToken) {
        unawaited(_registerIfChanged(newToken));
      });
    } catch (e, st) {
      debugPrint('FCMTokenService: initialize failed: $e\n$st');
    }
  }

  Future<void> resync() async {
    if (_currentToken == null) return;
    await _registerOrUpdate(_currentToken!, forceSync: true);
  }

  Future<void> onSignOut() async {
    try {
      final deviceId = await _ref.read(deviceIdProvider.future);
      final dio = _ref.read(apiClientProvider);
      await dio.delete('/v1/me/notifications/installations/$deviceId');
      debugPrint('FCMTokenService: unbound installation on sign-out');
    } catch (e) {
      debugPrint('FCMTokenService: unbind on sign-out failed: $e');
    }
  }

  Future<void> _registerIfChanged(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final lastToken = prefs.getString(_lastTokenKey);
    if (lastToken == token) {
      _currentToken = token;
      return;
    }
    await _registerOrUpdate(token);
  }

  Future<void> _registerOrUpdate(String token, {bool forceSync = false}) async {
    try {
      _currentToken = token;
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

      final locale = Platform.localeName;

      final body = {
        'device_id': deviceId,
        'platform': platform,
        'fcm_token': token,
        'permission_status': 'authorized',
        'timezone_iana': timezoneIana,
        'timezone_offset_minutes': timezoneOffsetMinutes,
        'app_version': appVersion,
        'build_number': buildNumber,
        'locale': locale,
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastTokenKey, token);

      debugPrint(
        'FCMTokenService: registered (${authState.isSignedIn ? "auth" : "guest"})',
      );
    } catch (e) {
      debugPrint('FCMTokenService: registration failed: $e');
    }
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
  }
}
