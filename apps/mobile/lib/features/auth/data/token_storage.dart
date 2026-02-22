import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/models/user_models.dart';
import '../../../shared/secure_storage/secure_storage.dart';

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.accessTokenExpiresAtUtc,
    required this.refreshToken,
    required this.refreshTokenExpiresAtUtc,
  });

  final String accessToken;
  final DateTime accessTokenExpiresAtUtc;
  final String refreshToken;
  final DateTime refreshTokenExpiresAtUtc;
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return TokenStorage(storage);
});

class TokenStorage {
  TokenStorage(this._storage);

  final SecureStorage _storage;

  static const _kAccessToken = 'auth.access_token';
  static const _kAccessExpiresAtUtc = 'auth.access_expires_at_utc';
  static const _kRefreshToken = 'auth.refresh_token';
  static const _kRefreshExpiresAtUtc = 'auth.refresh_expires_at_utc';
  static const _kUserProfileJson = 'auth.user_profile_json';

  Future<String?> readAccessToken() => _storage.readString(_kAccessToken);

  Future<DateTime?> readAccessTokenExpiresAtUtc() =>
      _storage.readDateTimeUtc(_kAccessExpiresAtUtc);

  Future<String?> readRefreshToken() => _storage.readString(_kRefreshToken);

  Future<DateTime?> readRefreshTokenExpiresAtUtc() =>
      _storage.readDateTimeUtc(_kRefreshExpiresAtUtc);

  Future<AuthTokens?> readTokens() async {
    final accessToken = await readAccessToken();
    final accessExp = await readAccessTokenExpiresAtUtc();
    final refreshToken = await readRefreshToken();
    final refreshExp = await readRefreshTokenExpiresAtUtc();

    if (accessToken == null ||
        accessExp == null ||
        refreshToken == null ||
        refreshExp == null) {
      return null;
    }

    return AuthTokens(
      accessToken: accessToken,
      accessTokenExpiresAtUtc: accessExp,
      refreshToken: refreshToken,
      refreshTokenExpiresAtUtc: refreshExp,
    );
  }

  Future<UserProfile?> readUserProfile() async {
    final raw = await _storage.readString(_kUserProfileJson);
    if (raw == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      return UserProfile.fromJson(decoded.cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  Future<void> writeUserProfile(UserProfile profile) async {
    await _storage.writeString(_kUserProfileJson, jsonEncode(profile.toJson()));
  }

  Future<void> writeTokens(AuthTokens tokens) async {
    await _storage.writeString(_kAccessToken, tokens.accessToken);
    await _storage.writeDateTimeUtc(
      _kAccessExpiresAtUtc,
      tokens.accessTokenExpiresAtUtc,
    );
    await _storage.writeString(_kRefreshToken, tokens.refreshToken);
    await _storage.writeDateTimeUtc(
      _kRefreshExpiresAtUtc,
      tokens.refreshTokenExpiresAtUtc,
    );
  }

  Future<bool> hasTokens() async {
    final tokens = await readTokens();
    return tokens != null;
  }

  Future<void> clearAll() async {
    await _storage.delete(_kAccessToken);
    await _storage.delete(_kAccessExpiresAtUtc);
    await _storage.delete(_kRefreshToken);
    await _storage.delete(_kRefreshExpiresAtUtc);
    await _storage.delete(_kUserProfileJson);
  }
}
