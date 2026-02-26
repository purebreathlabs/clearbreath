import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/models/auth_models.dart';
import '../../../core/network/models/user_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final raw = ref.watch(rawApiClientProvider);
  final authed = ref.watch(apiClientProvider);
  return AuthRepository(raw: raw, authed: authed);
});

class AuthRepository {
  AuthRepository({required Dio raw, required Dio authed})
    : _raw = raw,
      _authed = authed;

  final Dio _raw;
  final Dio _authed;

  Future<AuthResponse> signInWithProvider({
    required String provider,
    required String idToken,
    required String deviceId,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final headers = <String, dynamic>{};
    if (provider == 'dev' && AppConfig.devAuthEnabled) {
      final secret = AppConfig.devAuthSecret.trim();
      if (secret.isNotEmpty) {
        headers['X-Dev-Auth'] = secret;
      }
    }

    final resp = await _raw.post<dynamic>(
      '/v1/auth/provider_sign_in',
      data: ProviderSignInRequest(
        provider: provider,
        idToken: idToken,
        deviceId: deviceId,
        firstName: firstName,
        lastName: lastName,
        email: email,
      ).toJson(),
      options: headers.isEmpty ? null : Options(headers: headers),
    );

    final data = resp.data;
    if (data is! Map) {
      throw FormatException('Invalid sign-in response.');
    }
    return AuthResponse.fromJson(data.cast<String, dynamic>());
  }

  Future<AuthResponse> refreshToken({
    required String refreshToken,
    required String deviceId,
  }) async {
    final resp = await _raw.post<dynamic>(
      '/v1/auth/refresh',
      data: RefreshRequest(
        refreshToken: refreshToken,
        deviceId: deviceId,
      ).toJson(),
    );
    final data = resp.data;
    if (data is! Map) {
      throw FormatException('Invalid refresh response.');
    }
    return AuthResponse.fromJson(data.cast<String, dynamic>());
  }

  Future<void> logout({required String deviceId}) async {
    await _authed.post<void>(
      '/v1/auth/logout',
      data: LogoutRequest(deviceId: deviceId).toJson(),
    );
  }

  Future<void> deleteAccount() async {
    await _authed.delete<void>('/v1/me');
  }

  Future<UserProfile> fetchProfile() async {
    final resp = await _authed.get<dynamic>('/v1/me');
    final data = resp.data;
    if (data is! Map) {
      throw FormatException('Invalid profile response.');
    }
    return UserProfile.fromJson(data.cast<String, dynamic>());
  }

  Future<UserProfile> updateProfile(MePatchRequest request) async {
    final resp = await _authed.patch<dynamic>('/v1/me', data: request.toJson());
    final data = resp.data;
    if (data is! Map) {
      throw FormatException('Invalid profile response.');
    }
    return UserProfile.fromJson(data.cast<String, dynamic>());
  }
}
