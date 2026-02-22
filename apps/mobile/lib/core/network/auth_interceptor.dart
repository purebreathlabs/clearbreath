import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/device_id_store.dart';
import '../../features/auth/data/token_storage.dart';
import '../../features/auth/domain/auth_state_provider.dart';
import 'api_error.dart';
import 'models/auth_models.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.ref,
    required this.dio,
    required this.refreshDio,
    required this.tokens,
  });

  final Ref ref;
  final Dio dio;
  final Dio refreshDio;
  final TokenStorage tokens;

  Future<AuthTokens?>? _refreshInFlight;

  static const _kRetriedKey = 'auth.retried';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final access = await tokens.readAccessToken();
      if (access != null) {
        options.headers.putIfAbsent('Authorization', () => 'Bearer $access');
      }
    } catch (_) {}
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final request = err.requestOptions;

    if (response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final alreadyRetried = request.extra[_kRetriedKey] == true;
    if (alreadyRetried) {
      handler.next(err);
      return;
    }

    if (_isAuthPath(request.path)) {
      handler.next(err);
      return;
    }

    try {
      final nextTokens = await _refreshTokensSingleFlight();
      if (nextTokens == null) {
        handler.next(err);
        return;
      }

      request.extra[_kRetriedKey] = true;
      request.headers['Authorization'] = 'Bearer ${nextTokens.accessToken}';
      final retried = await dio.fetch<dynamic>(request);
      handler.resolve(retried);
    } catch (_) {
      handler.next(err);
    }
  }

  bool _isAuthPath(String path) {
    if (path.contains('/v1/auth/refresh')) {
      return true;
    }
    if (path.contains('/v1/auth/provider_sign_in')) {
      return true;
    }
    return false;
  }

  Future<AuthTokens?> _refreshTokensSingleFlight() async {
    final existing = _refreshInFlight;
    if (existing != null) {
      return existing;
    }

    final completer = Completer<AuthTokens?>();
    _refreshInFlight = completer.future;

    try {
      final refreshed = await _refreshTokens();
      completer.complete(refreshed);
      return refreshed;
    } catch (e, st) {
      completer.completeError(e, st);
      rethrow;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<AuthTokens?> _refreshTokens() async {
    final refreshToken = await tokens.readRefreshToken();
    final refreshExpiresAtUtc = await tokens.readRefreshTokenExpiresAtUtc();
    if (refreshToken == null || refreshExpiresAtUtc == null) {
      return null;
    }

    final now = DateTime.now().toUtc();
    if (!refreshExpiresAtUtc.isAfter(now)) {
      await tokens.clearAll();
      ref.invalidate(authStateProvider);
      return null;
    }

    final deviceId = await ref.read(deviceIdProvider.future);

    try {
      final resp = await refreshDio.post<dynamic>(
        '/v1/auth/refresh',
        data: RefreshRequest(
          refreshToken: refreshToken,
          deviceId: deviceId,
        ).toJson(),
      );

      final data = resp.data;
      if (data is! Map) {
        throw DioException(
          requestOptions: resp.requestOptions,
          response: resp,
          type: DioExceptionType.badResponse,
        );
      }

      final parsed = AuthResponse.fromJson(data.cast<String, dynamic>());
      final next = AuthTokens(
        accessToken: parsed.accessToken,
        accessTokenExpiresAtUtc: parsed.accessTokenExpiresAtUtc,
        refreshToken: parsed.refreshToken,
        refreshTokenExpiresAtUtc: parsed.refreshTokenExpiresAtUtc,
      );
      await tokens.writeTokens(next);
      return next;
    } on DioException catch (e) {
      final apiError = ApiError.fromDioException(e);
      if (apiError.isUnauthorized || apiError.isRefreshReplay) {
        await tokens.clearAll();
        ref.invalidate(authStateProvider);
      }
      return null;
    }
  }
}
