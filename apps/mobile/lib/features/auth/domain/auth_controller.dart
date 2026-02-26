import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../../core/network/models/user_models.dart';
import '../../../shared/providers/app_database_provider.dart';
import '../../intro/domain/intro_gate.dart';
import '../../onboarding/domain/onboarding_gate.dart';
import '../data/auth_repository.dart';
import '../data/device_id_store.dart';
import '../data/token_storage.dart';
import 'auth_refresh_coordinator.dart';
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

  Future<void> signIn(
    AuthProvider provider, {
    required String idToken,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
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
        firstName: firstName,
        lastName: lastName,
        email: email,
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
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);
    final db = ref.read(appDatabaseProvider);
    final introGate = ref.read(introGateProvider);
    final onboardingGate = ref.read(onboardingGateProvider);

    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      await repo.logout(deviceId: deviceId);
    } catch (_) {}

    await storage.clearAll();
    await db.deleteAllData();
    introGate.reset();
    onboardingGate.reset();
    state = const AuthStateGuest();
  }

  Future<void> updateUsername(String username) async {
    final next = username.trim();
    if (next.isEmpty) {
      throw const ApiError(
        statusCode: 400,
        code: 'validation',
        message: 'Username is required.',
        requestId: null,
      );
    }

    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);

    try {
      final updated = await repo.updateProfile(MePatchRequest(username: next));
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

  Future<void> deleteAccount() async {
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);
    final db = ref.read(appDatabaseProvider);
    final introGate = ref.read(introGateProvider);
    final onboardingGate = ref.read(onboardingGateProvider);

    try {
      await repo.deleteAccount();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } finally {
      await storage.clearAll();
      await db.deleteAllData();
      introGate.reset();
      onboardingGate.reset();
      state = const AuthStateGuest();
    }
  }

  Future<void> restoreSession() async {
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);
    final coordinator = ref.read(authRefreshCoordinatorProvider);

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
      state = AuthStateSignedIn(profile: cachedProfile, sessionReady: false);
    }

    final shouldRefresh = !stored.accessTokenExpiresAtUtc.isAfter(
      now.add(const Duration(seconds: 30)),
    );

    if (shouldRefresh) {
      final outcome = await coordinator.refreshIfPossible();
      if (outcome != null) {
        state = AuthStateSignedIn(profile: outcome.user, sessionReady: true);
        return;
      }
      if (!await storage.hasTokens()) {
        return;
      }
      final fallback = await storage.readUserProfile();
      if (fallback != null) {
        state = AuthStateSignedIn(profile: fallback, sessionReady: true);
      }
      return;
    }

    try {
      final profile = await repo.fetchProfile();
      await storage.writeUserProfile(profile);
      state = AuthStateSignedIn(profile: profile, sessionReady: true);
    } on DioException catch (e) {
      final apiError = ApiError.fromDioException(e);
      if (!apiError.isUnauthorized) {
        final fallback = await storage.readUserProfile();
        if (fallback != null) {
          state = AuthStateSignedIn(profile: fallback, sessionReady: true);
        }
        return;
      }
      final outcome = await coordinator.refreshIfPossible();
      if (outcome != null) {
        state = AuthStateSignedIn(profile: outcome.user, sessionReady: true);
        return;
      }
      if (!await storage.hasTokens()) {
        return;
      }
      final fallback = await storage.readUserProfile();
      if (fallback != null) {
        state = AuthStateSignedIn(profile: fallback, sessionReady: true);
      }
    }
  }
}
