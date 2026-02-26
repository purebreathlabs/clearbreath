import 'json_parsing.dart';

class LeaderboardRow {
  const LeaderboardRow({
    required this.rank,
    required this.username,
    required this.avatarSeed,
    required this.totalXp,
    required this.level,
    required this.userId,
    this.name,
  });

  factory LeaderboardRow.fromJson(JsonMap json) {
    return LeaderboardRow(
      rank: readInt(json, 'rank'),
      username: readString(json, 'username'),
      name: readNullableString(json, 'name'),
      avatarSeed: readString(json, 'avatar_seed'),
      totalXp: readInt(json, 'total_xp'),
      level: readInt(json, 'level'),
      userId: readString(json, 'user_id'),
    );
  }

  final int rank;
  final String username;
  final String? name;
  final String avatarSeed;
  final int totalXp;
  final int level;
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
  const LeaderboardSelfUser({
    required this.rank,
    required this.totalXp,
    required this.level,
  });

  factory LeaderboardSelfUser.fromJson(JsonMap json) {
    return LeaderboardSelfUser(
      rank: readNullableInt(json, 'rank'),
      totalXp: readInt(json, 'total_xp'),
      level: readInt(json, 'level'),
    );
  }

  final int? rank;
  final int totalXp;
  final int level;
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
