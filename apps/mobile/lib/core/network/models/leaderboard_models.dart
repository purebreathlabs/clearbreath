import 'json_parsing.dart';

class LeaderboardRow {
  const LeaderboardRow({
    required this.rank,
    required this.displayNameOrInitials,
    required this.avatarSeed,
    required this.metricValue,
    required this.userId,
  });

  factory LeaderboardRow.fromJson(JsonMap json) {
    return LeaderboardRow(
      rank: readInt(json, 'rank'),
      displayNameOrInitials: readString(json, 'display_name_or_initials'),
      avatarSeed: readString(json, 'avatar_seed'),
      metricValue: readInt(json, 'metric_value'),
      userId: readString(json, 'user_id'),
    );
  }

  final int rank;
  final String displayNameOrInitials;
  final String avatarSeed;
  final int metricValue;
  final String userId;
}

class LeaderboardListResponse {
  const LeaderboardListResponse({
    required this.ranking,
    required this.generatedAtUtc,
    required this.top,
  });

  factory LeaderboardListResponse.fromJson(JsonMap json) {
    return LeaderboardListResponse(
      ranking: readString(json, 'ranking'),
      generatedAtUtc: readDateTimeUtc(json, 'generated_at_utc'),
      top: readMapList(
        json,
        'top',
      ).map(LeaderboardRow.fromJson).toList(growable: false),
    );
  }

  final String ranking;
  final DateTime generatedAtUtc;
  final List<LeaderboardRow> top;
}

class LeaderboardSelfUser {
  const LeaderboardSelfUser({required this.rank, required this.metricValue});

  factory LeaderboardSelfUser.fromJson(JsonMap json) {
    return LeaderboardSelfUser(
      rank: readNullableInt(json, 'rank'),
      metricValue: readInt(json, 'metric_value'),
    );
  }

  final int? rank;
  final int metricValue;
}

class LeaderboardSelfResponse {
  const LeaderboardSelfResponse({required this.ranking, required this.user});

  factory LeaderboardSelfResponse.fromJson(JsonMap json) {
    return LeaderboardSelfResponse(
      ranking: readString(json, 'ranking'),
      user: LeaderboardSelfUser.fromJson(readMap(json, 'user')),
    );
  }

  final String ranking;
  final LeaderboardSelfUser user;
}
