enum LeaderboardRanking { xp }

extension LeaderboardRankingX on LeaderboardRanking {
  String toQueryParam() => 'xp';

  String label() => 'XP';

  String metricLabel() => 'XP';
}
