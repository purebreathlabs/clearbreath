import 'json_parsing.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.avatarSeed,
    required this.leaderboardOptIn,
    required this.leaderboardInitialsOnly,
    required this.createdAtUtc,
    required this.timezoneOffsetMinutesLatest,
  });

  factory UserProfile.fromJson(JsonMap json) {
    return UserProfile(
      id: readString(json, 'id'),
      displayName: readString(json, 'display_name'),
      avatarSeed: readString(json, 'avatar_seed'),
      leaderboardOptIn: readBool(json, 'leaderboard_opt_in'),
      leaderboardInitialsOnly: readBool(json, 'leaderboard_initials_only'),
      createdAtUtc: readDateTimeUtc(json, 'created_at_utc'),
      timezoneOffsetMinutesLatest: readInt(json, 'timezone_offset_minutes_latest'),
    );
  }

  final String id;
  final String displayName;
  final String avatarSeed;
  final bool leaderboardOptIn;
  final bool leaderboardInitialsOnly;
  final DateTime createdAtUtc;
  final int timezoneOffsetMinutesLatest;

  JsonMap toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'avatar_seed': avatarSeed,
      'leaderboard_opt_in': leaderboardOptIn,
      'leaderboard_initials_only': leaderboardInitialsOnly,
      'created_at_utc': createdAtUtc.toUtc().toIso8601String(),
      'timezone_offset_minutes_latest': timezoneOffsetMinutesLatest,
    };
  }
}

class MePatchRequest {
  const MePatchRequest({
    this.displayName,
    this.leaderboardOptIn,
    this.leaderboardInitialsOnly,
  });

  final String? displayName;
  final bool? leaderboardOptIn;
  final bool? leaderboardInitialsOnly;

  JsonMap toJson() {
    final json = <String, dynamic>{};
    final name = displayName?.trim();
    if (name != null) {
      json['display_name'] = name;
    }
    final optIn = leaderboardOptIn;
    if (optIn != null) {
      json['leaderboard_opt_in'] = optIn;
    }
    final initialsOnly = leaderboardInitialsOnly;
    if (initialsOnly != null) {
      json['leaderboard_initials_only'] = initialsOnly;
    }
    return json;
  }
}
