import 'dart:collection';

import 'package:clearbreath/core/network/models/auth_models.dart';
import 'package:clearbreath/core/network/models/user_models.dart';
import 'package:clearbreath/features/auth/data/auth_repository.dart';
import 'package:clearbreath/features/auth/data/device_id_store.dart';
import 'package:clearbreath/features/auth/data/token_storage.dart';
import 'package:clearbreath/features/auth/domain/auth_controller.dart';
import 'package:clearbreath/features/auth/domain/auth_state.dart';
import 'package:clearbreath/features/auth/domain/auth_state_provider.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_answers.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_answers_provider.dart';
import 'package:clearbreath/shared/secure_storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sign-in stores tokens and sign-out clears them', () async {
    final storage = _MemorySecureStorage();
    final repo = _FakeAuthRepository()
      ..signInResult = _authResponse(
        accessToken: 'access1',
        refreshToken: 'refresh1',
        userId: 'user1',
        displayName: 'Breather123456',
      );

    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(storage),
        deviceIdProvider.overrideWith((ref) async => 'device1'),
        onboardingAnswersProvider.overrideWith(
          (ref) async => OnboardingAnswers.defaults(),
        ),
        authRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(authStateProvider.notifier);
    await controller.signIn(AuthProvider.dev, idToken: '');

    final signedIn = container.read(authStateProvider);
    expect(signedIn, isA<AuthStateSignedIn>());

    final tokens = await container.read(tokenStorageProvider).readTokens();
    expect(tokens, isNotNull);
    expect(tokens!.accessToken, equals('access1'));
    expect(tokens.refreshToken, equals('refresh1'));

    await controller.signOut();
    expect(container.read(authStateProvider), isA<AuthStateGuest>());
    expect(await container.read(tokenStorageProvider).readTokens(), isNull);
    expect(repo.logoutCalls, equals(1));
  });

  test('restoreSession refreshes when access token is expired', () async {
    final storage = _MemorySecureStorage();
    final repo = _FakeAuthRepository()
      ..refreshResult = _authResponse(
        accessToken: 'access2',
        refreshToken: 'refresh2',
        userId: 'user2',
        displayName: 'Breather999999',
      )
      ..profileResult = UserProfile(
        id: 'user2',
        displayName: 'Breather999999',
        avatarSeed: 'seed2',
        leaderboardOptIn: true,
        leaderboardInitialsOnly: false,
        createdAtUtc: DateTime.utc(2026, 2, 22, 0, 0),
        timezoneOffsetMinutesLatest: 0,
      );

    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(storage),
        deviceIdProvider.overrideWith((ref) async => 'device1'),
        onboardingAnswersProvider.overrideWith(
          (ref) async => OnboardingAnswers.defaults(),
        ),
        authRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final tokenStore = container.read(tokenStorageProvider);
    await tokenStore.writeTokens(
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
    await tokenStore.writeUserProfile(
      UserProfile(
        id: 'user2',
        displayName: 'Breather999999',
        avatarSeed: 'seed2',
        leaderboardOptIn: true,
        leaderboardInitialsOnly: false,
        createdAtUtc: DateTime.utc(2026, 2, 22, 0, 0),
        timezoneOffsetMinutesLatest: 0,
      ),
    );

    final controller = container.read(authStateProvider.notifier);
    await controller.restoreSession();

    expect(repo.refreshCalls, equals(1));
    expect(container.read(authStateProvider), isA<AuthStateSignedIn>());
    final tokens = await tokenStore.readTokens();
    expect(tokens, isNotNull);
    expect(tokens!.accessToken, equals('access2'));
    expect(tokens.refreshToken, equals('refresh2'));
  });

  test('sign-in passes first and last name to repository', () async {
    final storage = _MemorySecureStorage();
    final repo = _FakeAuthRepository()
      ..signInResult = _authResponse(
        accessToken: 'access1',
        refreshToken: 'refresh1',
        userId: 'user1',
        displayName: 'Jane Doe',
      );

    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(storage),
        deviceIdProvider.overrideWith((ref) async => 'device1'),
        onboardingAnswersProvider.overrideWith(
          (ref) async => OnboardingAnswers.defaults(),
        ),
        authRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(authStateProvider.notifier);
    await controller.signIn(
      AuthProvider.google,
      idToken: 'token',
      firstName: 'Jane',
      lastName: 'Doe',
    );

    expect(repo.lastFirstName, equals('Jane'));
    expect(repo.lastLastName, equals('Doe'));
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

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(raw: Dio(), authed: Dio());

  int logoutCalls = 0;
  int refreshCalls = 0;

  AuthResponse? signInResult;
  AuthResponse? refreshResult;
  UserProfile? profileResult;

  String? lastFirstName;
  String? lastLastName;

  @override
  Future<AuthResponse> signInWithProvider({
    required String provider,
    required String idToken,
    required String deviceId,
    String? firstName,
    String? lastName,
  }) async {
    lastFirstName = firstName;
    lastLastName = lastName;
    final result = signInResult;
    if (result == null) {
      throw StateError('missing signInResult');
    }
    return result;
  }

  @override
  Future<AuthResponse> refreshToken({
    required String refreshToken,
    required String deviceId,
  }) async {
    refreshCalls += 1;
    final result = refreshResult;
    if (result == null) {
      throw StateError('missing refreshResult');
    }
    return result;
  }

  @override
  Future<void> logout({required String deviceId}) async {
    logoutCalls += 1;
  }

  @override
  Future<UserProfile> fetchProfile() async {
    final result = profileResult;
    if (result == null) {
      throw StateError('missing profileResult');
    }
    return result;
  }
}

AuthResponse _authResponse({
  required String accessToken,
  required String refreshToken,
  required String userId,
  required String displayName,
}) {
  return AuthResponse(
    accessToken: accessToken,
    accessTokenExpiresAtUtc: DateTime.now().toUtc().add(
      const Duration(hours: 1),
    ),
    refreshToken: refreshToken,
    refreshTokenExpiresAtUtc: DateTime.now().toUtc().add(
      const Duration(days: 30),
    ),
    user: UserProfile(
      id: userId,
      displayName: displayName,
      avatarSeed: 'seed',
      leaderboardOptIn: true,
      leaderboardInitialsOnly: false,
      createdAtUtc: DateTime.utc(2026, 2, 22, 0, 0),
      timezoneOffsetMinutesLatest: 0,
    ),
  );
}
