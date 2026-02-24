import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/models/auth_models.dart';
import '../../../core/network/models/user_models.dart';
import '../data/device_id_store.dart';
import '../data/token_storage.dart';
import 'auth_state_provider.dart';

@immutable
class RefreshOutcome {
  const RefreshOutcome({required this.tokens, required this.user});

  final AuthTokens tokens;
  final UserProfile user;
}

final authRefreshCoordinatorProvider = Provider<AuthRefreshCoordinator>((ref) {
  final rawDio = ref.watch(rawApiClientProvider);
  final tokens = ref.watch(tokenStorageProvider);
  return AuthRefreshCoordinator(ref: ref, rawDio: rawDio, tokens: tokens);
});

class AuthRefreshCoordinator {
  AuthRefreshCoordinator({
    required this.ref,
    required Dio rawDio,
    required TokenStorage tokens,
  }) : _rawDio = rawDio,
       _tokens = tokens;

  final Ref ref;
  final Dio _rawDio;
  final TokenStorage _tokens;

  Future<RefreshOutcome?>? _inFlight;

  Future<RefreshOutcome?> refreshIfPossible() {
    final existing = _inFlight;
    if (existing != null) {
      return existing;
    }

    final completer = Completer<RefreshOutcome?>();
    _inFlight = completer.future;

    _doRefresh()
        .then(completer.complete, onError: completer.completeError)
        .whenComplete(() {
          _inFlight = null;
        });

    return completer.future;
  }

  Future<RefreshOutcome?> _doRefresh() async {
    final refreshToken = await _tokens.readRefreshToken();
    final refreshExpiresAtUtc = await _tokens.readRefreshTokenExpiresAtUtc();

    if (refreshToken == null || refreshExpiresAtUtc == null) {
      return null;
    }

    final now = DateTime.now().toUtc();
    if (!refreshExpiresAtUtc.isAfter(now)) {
      await _tokens.clearAll();
      ref.invalidate(authStateProvider);
      return null;
    }

    final deviceId = await ref.read(deviceIdProvider.future);

    try {
      final resp = await _rawDio.post<dynamic>(
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
      await _tokens.writeTokens(next);
      await _tokens.writeUserProfile(parsed.user);
      return RefreshOutcome(tokens: next, user: parsed.user);
    } on DioException catch (e) {
      final apiError = ApiError.fromDioException(e);

      if (apiError.isUnauthorized) {
        await _tokens.clearAll();
        ref.invalidate(authStateProvider);
        return null;
      }

      if (apiError.isRefreshReplay) {
        final currentToken = await _tokens.readRefreshToken();
        if (currentToken != null && currentToken != refreshToken) {
          final stored = await _tokens.readTokens();
          final profile = await _tokens.readUserProfile();
          if (stored != null && profile != null) {
            return RefreshOutcome(tokens: stored, user: profile);
          }
        }
        await _tokens.clearAll();
        ref.invalidate(authStateProvider);
        return null;
      }

      return null;
    }
  }
}
