import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:clearbreath/core/network/api_client.dart';
import 'package:clearbreath/features/auth/data/device_id_store.dart';
import 'package:clearbreath/features/auth/data/token_storage.dart';
import 'package:clearbreath/shared/secure_storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('attaches bearer token when present', () async {
    final store = _MemorySecureStorage();
    final refreshDio = Dio();
    refreshDio.httpClientAdapter = _TestAdapter((options) async {
      return ResponseBody.fromString(
        '{}',
        500,
        headers: {
          'content-type': ['application/json'],
        },
      );
    });

    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(store),
        deviceIdProvider.overrideWith((ref) async => 'device1'),
        rawApiClientProvider.overrideWithValue(refreshDio),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(tokenStorageProvider)
        .writeTokens(
          AuthTokens(
            accessToken: 'access1',
            accessTokenExpiresAtUtc: DateTime.now().toUtc().add(
              const Duration(hours: 1),
            ),
            refreshToken: 'refresh1',
            refreshTokenExpiresAtUtc: DateTime.now().toUtc().add(
              const Duration(days: 30),
            ),
          ),
        );

    final dio = container.read(apiClientProvider);
    dio.httpClientAdapter = _TestAdapter((options) async {
      expect(options.headers['Authorization'], equals('Bearer access1'));
      return ResponseBody.fromString(
        '{}',
        200,
        headers: {
          'content-type': ['application/json'],
        },
      );
    });

    final resp = await dio.get<dynamic>('/v1/me');
    expect(resp.statusCode, equals(200));
  });

  test('refreshes once on 401 and retries original request', () async {
    final store = _MemorySecureStorage();
    var refreshCalls = 0;

    final refreshDio = Dio();
    refreshDio.httpClientAdapter = _TestAdapter((options) async {
      if (options.path != '/v1/auth/refresh') {
        return ResponseBody.fromString(
          '{"error":"not_found","code":"not_found","request_id":"r"}',
          404,
          headers: {
            'content-type': ['application/json'],
          },
        );
      }
      refreshCalls += 1;
      return ResponseBody.fromString(
        _authResponseJson(
          accessToken: 'access2',
          refreshToken: 'refresh2',
          userId: 'user1',
        ),
        200,
        headers: {
          'content-type': ['application/json'],
        },
      );
    });

    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(store),
        deviceIdProvider.overrideWith((ref) async => 'device1'),
        rawApiClientProvider.overrideWithValue(refreshDio),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(tokenStorageProvider)
        .writeTokens(
          AuthTokens(
            accessToken: 'expired_access',
            accessTokenExpiresAtUtc: DateTime.now().toUtc().subtract(
              const Duration(minutes: 1),
            ),
            refreshToken: 'refresh1',
            refreshTokenExpiresAtUtc: DateTime.now().toUtc().add(
              const Duration(days: 30),
            ),
          ),
        );

    final dio = container.read(apiClientProvider);
    dio.httpClientAdapter = _TestAdapter((options) async {
      final auth = options.headers['Authorization'];
      if (auth == 'Bearer expired_access') {
        return ResponseBody.fromString(
          '{"error":"unauthorized","code":"unauthorized","request_id":"r"}',
          401,
          headers: {
            'content-type': ['application/json'],
          },
        );
      }
      expect(auth, equals('Bearer access2'));
      return ResponseBody.fromString(
        '{}',
        200,
        headers: {
          'content-type': ['application/json'],
        },
      );
    });

    final resp = await dio.get<dynamic>('/v1/me');
    expect(resp.statusCode, equals(200));
    expect(refreshCalls, equals(1));

    final tokens = await container.read(tokenStorageProvider).readTokens();
    expect(tokens, isNotNull);
    expect(tokens!.accessToken, equals('access2'));
    expect(tokens.refreshToken, equals('refresh2'));
  });

  test('clears tokens when refresh fails with refresh_replay', () async {
    final store = _MemorySecureStorage();

    final refreshDio = Dio();
    refreshDio.httpClientAdapter = _TestAdapter((options) async {
      return ResponseBody.fromString(
        '{"error":"replay","code":"refresh_replay","request_id":"r"}',
        409,
        headers: {
          'content-type': ['application/json'],
        },
      );
    });

    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(store),
        deviceIdProvider.overrideWith((ref) async => 'device1'),
        rawApiClientProvider.overrideWithValue(refreshDio),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(tokenStorageProvider)
        .writeTokens(
          AuthTokens(
            accessToken: 'expired_access',
            accessTokenExpiresAtUtc: DateTime.now().toUtc().subtract(
              const Duration(minutes: 1),
            ),
            refreshToken: 'refresh1',
            refreshTokenExpiresAtUtc: DateTime.now().toUtc().add(
              const Duration(days: 30),
            ),
          ),
        );

    final dio = container.read(apiClientProvider);
    dio.httpClientAdapter = _TestAdapter((options) async {
      return ResponseBody.fromString(
        '{"error":"unauthorized","code":"unauthorized","request_id":"r"}',
        401,
        headers: {
          'content-type': ['application/json'],
        },
      );
    });

    await expectLater(dio.get<dynamic>('/v1/me'), throwsA(isA<DioException>()));

    expect(await container.read(tokenStorageProvider).readTokens(), isNull);
  });

  test(
    'replay recovery preserves session when concurrent refresh succeeded',
    () async {
      final store = _MemorySecureStorage();
      var refreshCalls = 0;

      final refreshDio = Dio();
      refreshDio.httpClientAdapter = _TestAdapter((options) async {
        refreshCalls += 1;
        await store.writeString('auth.refresh_token', 'refresh2');
        await store.writeDateTimeUtc(
          'auth.refresh_expires_at_utc',
          DateTime.now().toUtc().add(const Duration(days: 30)),
        );
        await store.writeString('auth.access_token', 'access2');
        await store.writeDateTimeUtc(
          'auth.access_expires_at_utc',
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        );
        await store.writeString(
          'auth.user_profile_json',
          '{"id":"user1","display_name":"Breather123456","avatar_seed":"seed","leaderboard_opt_in":true,"leaderboard_initials_only":false,"created_at_utc":"2026-02-22T00:00:00Z","timezone_offset_minutes_latest":0}',
        );
        return ResponseBody.fromString(
          '{"error":"replay","code":"refresh_replay","request_id":"r"}',
          409,
          headers: {
            'content-type': ['application/json'],
          },
        );
      });

      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(store),
          deviceIdProvider.overrideWith((ref) async => 'device1'),
          rawApiClientProvider.overrideWithValue(refreshDio),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(tokenStorageProvider)
          .writeTokens(
            AuthTokens(
              accessToken: 'expired_access',
              accessTokenExpiresAtUtc: DateTime.now().toUtc().subtract(
                const Duration(minutes: 1),
              ),
              refreshToken: 'refresh1',
              refreshTokenExpiresAtUtc: DateTime.now().toUtc().add(
                const Duration(days: 30),
              ),
            ),
          );

      final dio = container.read(apiClientProvider);
      dio.httpClientAdapter = _TestAdapter((options) async {
        final auth = options.headers['Authorization'];
        if (auth == 'Bearer expired_access') {
          return ResponseBody.fromString(
            '{"error":"unauthorized","code":"unauthorized","request_id":"r"}',
            401,
            headers: {
              'content-type': ['application/json'],
            },
          );
        }
        expect(auth, equals('Bearer access2'));
        return ResponseBody.fromString(
          '{}',
          200,
          headers: {
            'content-type': ['application/json'],
          },
        );
      });

      final resp = await dio.get<dynamic>('/v1/me');
      expect(resp.statusCode, equals(200));
      expect(refreshCalls, equals(1));
      expect(
        await container.read(tokenStorageProvider).readTokens(),
        isNotNull,
      );
    },
  );

  test('single-flight refresh across concurrent 401 responses', () async {
    final store = _MemorySecureStorage();
    var refreshCalls = 0;

    final refreshDio = Dio();
    refreshDio.httpClientAdapter = _TestAdapter((options) async {
      refreshCalls += 1;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return ResponseBody.fromString(
        _authResponseJson(
          accessToken: 'access2',
          refreshToken: 'refresh2',
          userId: 'user1',
        ),
        200,
        headers: {
          'content-type': ['application/json'],
        },
      );
    });

    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(store),
        deviceIdProvider.overrideWith((ref) async => 'device1'),
        rawApiClientProvider.overrideWithValue(refreshDio),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(tokenStorageProvider)
        .writeTokens(
          AuthTokens(
            accessToken: 'expired_access',
            accessTokenExpiresAtUtc: DateTime.now().toUtc().subtract(
              const Duration(minutes: 1),
            ),
            refreshToken: 'refresh1',
            refreshTokenExpiresAtUtc: DateTime.now().toUtc().add(
              const Duration(days: 30),
            ),
          ),
        );

    final dio = container.read(apiClientProvider);
    dio.httpClientAdapter = _TestAdapter((options) async {
      final auth = options.headers['Authorization'];
      if (auth == 'Bearer expired_access') {
        return ResponseBody.fromString(
          '{"error":"unauthorized","code":"unauthorized","request_id":"r"}',
          401,
          headers: {
            'content-type': ['application/json'],
          },
        );
      }
      expect(auth, equals('Bearer access2'));
      return ResponseBody.fromString(
        '{}',
        200,
        headers: {
          'content-type': ['application/json'],
        },
      );
    });

    final results = await Future.wait([
      dio.get<dynamic>('/v1/me'),
      dio.get<dynamic>('/v1/me'),
    ]);

    expect(results[0].statusCode, equals(200));
    expect(results[1].statusCode, equals(200));
    expect(refreshCalls, equals(1));
  });
}

class _MemorySecureStorage implements SecureStorage {
  final Map<String, String> _values = HashMap();

  @override
  Future<String?> readString(String key) async => _values[key];

  @override
  Future<void> writeString(String key, String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _values.remove(key);
      return;
    }
    _values[key] = trimmed;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _values.clear();
  }

  @override
  Future<DateTime?> readDateTimeUtc(String key) async {
    final raw = _values[key];
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(raw).toUtc();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> writeDateTimeUtc(String key, DateTime value) async {
    _values[key] = value.toUtc().toIso8601String();
  }
}

class _TestAdapter implements HttpClientAdapter {
  _TestAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

String _authResponseJson({
  required String accessToken,
  required String refreshToken,
  required String userId,
}) {
  final accessExp = DateTime.now()
      .toUtc()
      .add(const Duration(hours: 1))
      .toIso8601String();
  final refreshExp = DateTime.now()
      .toUtc()
      .add(const Duration(days: 30))
      .toIso8601String();

  return '''
{
  "access_token":"$accessToken",
  "access_token_expires_at_utc":"$accessExp",
  "refresh_token":"$refreshToken",
  "refresh_token_expires_at_utc":"$refreshExp",
  "user":{
    "id":"$userId",
    "display_name":"Breather123456",
    "avatar_seed":"seed",
    "leaderboard_opt_in":true,
    "leaderboard_initials_only":false,
    "created_at_utc":"2026-02-22T00:00:00Z",
    "timezone_offset_minutes_latest":0
  }
}
''';
}
