import 'json_parsing.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.name,
    required this.avatarSeed,
    required this.leaderboardOptIn,
    required this.createdAtUtc,
    required this.timezoneOffsetMinutesLatest,
  });

  factory UserProfile.fromJson(JsonMap json) {
    return UserProfile(
      id: readString(json, 'id'),
      username: readString(json, 'username'),
      name: readNullableString(json, 'name') ?? '',
      avatarSeed: readString(json, 'avatar_seed'),
      leaderboardOptIn: readBool(json, 'leaderboard_opt_in'),
      createdAtUtc: readDateTimeUtc(json, 'created_at_utc'),
      timezoneOffsetMinutesLatest: readInt(
        json,
        'timezone_offset_minutes_latest',
      ),
    );
  }

  final String id;
  final String username;
  final String name;
  final String avatarSeed;
  final bool leaderboardOptIn;
  final DateTime createdAtUtc;
  final int timezoneOffsetMinutesLatest;

  JsonMap toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'avatar_seed': avatarSeed,
      'leaderboard_opt_in': leaderboardOptIn,
      'created_at_utc': createdAtUtc.toUtc().toIso8601String(),
      'timezone_offset_minutes_latest': timezoneOffsetMinutesLatest,
    };
  }
}

class MePatchRequest {
  const MePatchRequest({this.username, this.leaderboardOptIn});

  final String? username;
  final bool? leaderboardOptIn;

  JsonMap toJson() {
    final json = <String, dynamic>{};
    final u = username?.trim();
    if (u != null) {
      json['username'] = u;
    }
    final optIn = leaderboardOptIn;
    if (optIn != null) {
      json['leaderboard_opt_in'] = optIn;
    }
    return json;
  }
}
