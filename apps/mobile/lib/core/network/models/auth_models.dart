import 'json_parsing.dart';
import 'user_models.dart';

class ProviderSignInRequest {
  const ProviderSignInRequest({
    required this.provider,
    required this.idToken,
    required this.deviceId,
    required this.birthYear,
  });

  final String provider;
  final String idToken;
  final String deviceId;
  final int birthYear;

  JsonMap toJson() {
    return {
      'provider': provider,
      'id_token': idToken,
      'device_id': deviceId,
      'birth_year': birthYear,
    };
  }
}

class RefreshRequest {
  const RefreshRequest({required this.refreshToken, required this.deviceId});

  final String refreshToken;
  final String deviceId;

  JsonMap toJson() {
    return {
      'refresh_token': refreshToken,
      'device_id': deviceId,
    };
  }
}

class LogoutRequest {
  const LogoutRequest({required this.deviceId});

  final String deviceId;

  JsonMap toJson() {
    return {'device_id': deviceId};
  }
}

class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.accessTokenExpiresAtUtc,
    required this.refreshToken,
    required this.refreshTokenExpiresAtUtc,
    required this.user,
  });

  factory AuthResponse.fromJson(JsonMap json) {
    return AuthResponse(
      accessToken: readString(json, 'access_token'),
      accessTokenExpiresAtUtc: readDateTimeUtc(
        json,
        'access_token_expires_at_utc',
      ),
      refreshToken: readString(json, 'refresh_token'),
      refreshTokenExpiresAtUtc: readDateTimeUtc(
        json,
        'refresh_token_expires_at_utc',
      ),
      user: UserProfile.fromJson(readMap(json, 'user')),
    );
  }

  final String accessToken;
  final DateTime accessTokenExpiresAtUtc;
  final String refreshToken;
  final DateTime refreshTokenExpiresAtUtc;
  final UserProfile user;
}

