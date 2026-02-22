import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../../core/network/models/user_models.dart';
import '../../onboarding/domain/onboarding_answers_provider.dart';
import '../data/auth_repository.dart';
import '../data/device_id_store.dart';
import '../data/token_storage.dart';
import 'auth_state.dart';

enum AuthProvider { apple, google, dev }

class AuthController extends Notifier<AuthState> {
  var _restoreStarted = false;

  @override
  AuthState build() {
    if (!_restoreStarted && !Platform.environment.containsKey('FLUTTER_TEST')) {
      _restoreStarted = true;
      unawaited(restoreSession());
    }
    return const AuthStateGuest();
  }

  Future<void> signIn(AuthProvider provider, {required String idToken}) async {
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);
    final deviceId = await ref.read(deviceIdProvider.future);

    final providerKey = switch (provider) {
      AuthProvider.apple => 'apple',
      AuthProvider.google => 'google',
      AuthProvider.dev => 'dev',
    };

    final safeToken = idToken.trim();
    if (provider != AuthProvider.dev && safeToken.isEmpty) {
      throw const ApiError(
        statusCode: 400,
        code: 'validation',
        message: 'Missing provider token.',
        requestId: null,
      );
    }

    try {
      final resp = await repo.signInWithProvider(
        provider: providerKey,
        idToken: safeToken,
        deviceId: deviceId,
      );

      await storage.writeTokens(
        AuthTokens(
          accessToken: resp.accessToken,
          accessTokenExpiresAtUtc: resp.accessTokenExpiresAtUtc,
          refreshToken: resp.refreshToken,
          refreshTokenExpiresAtUtc: resp.refreshTokenExpiresAtUtc,
        ),
      );
      await storage.writeUserProfile(resp.user);
      state = AuthStateSignedIn(profile: resp.user);

      await _syncDisplayNameFromOnboarding(current: resp.user);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);

    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      await repo.logout(deviceId: deviceId);
    } catch (_) {}

    await storage.clearAll();
    state = const AuthStateGuest();
  }

  Future<void> updateDisplayName(String displayName) async {
    final next = displayName.trim();
    if (next.isEmpty) {
      throw const ApiError(
        statusCode: 400,
        code: 'validation',
        message: 'Display name is required.',
        requestId: null,
      );
    }

    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);

    try {
      final updated = await repo.updateProfile(
        MePatchRequest(displayName: next),
      );
      await storage.writeUserProfile(updated);
      state = AuthStateSignedIn(profile: updated);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> setLeaderboardOptIn(bool value) async {
    final current = state;
    if (current is! AuthStateSignedIn) {
      return;
    }

    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);

    try {
      final updated = await repo.updateProfile(
        MePatchRequest(leaderboardOptIn: value),
      );
      await storage.writeUserProfile(updated);
      state = AuthStateSignedIn(profile: updated);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> setLeaderboardInitialsOnly(bool value) async {
    final current = state;
    if (current is! AuthStateSignedIn) {
      return;
    }

    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);

    try {
      final updated = await repo.updateProfile(
        MePatchRequest(leaderboardInitialsOnly: value),
      );
      await storage.writeUserProfile(updated);
      state = AuthStateSignedIn(profile: updated);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> deleteAccount() async {
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);

    try {
      await repo.deleteAccount();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } finally {
      await storage.clearAll();
      state = const AuthStateGuest();
    }
  }

  Future<void> restoreSession() async {
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);

    final stored = await storage.readTokens();
    if (stored == null) {
      state = const AuthStateGuest();
      return;
    }

    final now = DateTime.now().toUtc();
    if (!stored.refreshTokenExpiresAtUtc.isAfter(now)) {
      await storage.clearAll();
      state = const AuthStateGuest();
      return;
    }

    final cachedProfile = await storage.readUserProfile();
    if (cachedProfile != null) {
      state = AuthStateSignedIn(profile: cachedProfile);
    }

    final shouldRefresh = !stored.accessTokenExpiresAtUtc.isAfter(
      now.add(const Duration(seconds: 30)),
    );

    if (shouldRefresh) {
      await _refreshAndSetState(
        repo: repo,
        storage: storage,
        refreshToken: stored.refreshToken,
      );
      return;
    }

    try {
      final profile = await repo.fetchProfile();
      await storage.writeUserProfile(profile);
      state = AuthStateSignedIn(profile: profile);
    } on DioException catch (e) {
      final apiError = ApiError.fromDioException(e);
      if (!apiError.isUnauthorized) {
        return;
      }
      await _refreshAndSetState(
        repo: repo,
        storage: storage,
        refreshToken: stored.refreshToken,
      );
    }
  }

  Future<void> _refreshAndSetState({
    required AuthRepository repo,
    required TokenStorage storage,
    required String refreshToken,
  }) async {
    final deviceId = await ref.read(deviceIdProvider.future);

    try {
      final resp = await repo.refreshToken(
        refreshToken: refreshToken,
        deviceId: deviceId,
      );

      await storage.writeTokens(
        AuthTokens(
          accessToken: resp.accessToken,
          accessTokenExpiresAtUtc: resp.accessTokenExpiresAtUtc,
          refreshToken: resp.refreshToken,
          refreshTokenExpiresAtUtc: resp.refreshTokenExpiresAtUtc,
        ),
      );
      await storage.writeUserProfile(resp.user);
      state = AuthStateSignedIn(profile: resp.user);
    } on DioException catch (e) {
      final apiError = ApiError.fromDioException(e);
      if (apiError.isUnauthorized || apiError.isRefreshReplay) {
        await storage.clearAll();
        state = const AuthStateGuest();
      }
    }
  }

  Future<void> _syncDisplayNameFromOnboarding({
    required UserProfile current,
  }) async {
    final next = (await ref.read(
      onboardingAnswersProvider.future,
    )).displayName.trim();
    if (next.isEmpty) {
      return;
    }
    if (next == current.displayName.trim()) {
      return;
    }

    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);

    try {
      final updated = await repo.updateProfile(
        MePatchRequest(displayName: next),
      );
      await storage.writeUserProfile(updated);
      state = AuthStateSignedIn(profile: updated);
    } on DioException catch (e) {
      final apiError = ApiError.fromDioException(e);
      if (apiError.statusCode == 400 && apiError.code == 'validation') {
        return;
      }
    }
  }
}
