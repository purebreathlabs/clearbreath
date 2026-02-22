enum LeaderboardRanking { streak, weekly, allTime }

extension LeaderboardRankingX on LeaderboardRanking {
  String toQueryParam() {
    return switch (this) {
      LeaderboardRanking.streak => 'streak',
      LeaderboardRanking.weekly => 'weekly',
      LeaderboardRanking.allTime => 'all_time',
    };
  }

  String label() {
    return switch (this) {
      LeaderboardRanking.streak => 'Streak',
      LeaderboardRanking.weekly => 'Weekly',
      LeaderboardRanking.allTime => 'All time',
    };
  }

  String metricLabel() {
    return switch (this) {
      LeaderboardRanking.streak => 'days',
      LeaderboardRanking.weekly => 'min',
      LeaderboardRanking.allTime => 'min',
    };
  }
}
