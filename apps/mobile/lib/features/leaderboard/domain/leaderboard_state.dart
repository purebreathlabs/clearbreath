import 'package:flutter/foundation.dart';

import 'leaderboard_entry.dart';
import 'leaderboard_ranking.dart';

@immutable
class LeaderboardState {
  const LeaderboardState({
    required this.ranking,
    required this.loading,
    required this.entries,
    required this.self,
    required this.generatedAtUtc,
    required this.fetchedAtUtc,
    required this.bannerMessage,
    required this.errorMessage,
  });

  factory LeaderboardState.initial() {
    return const LeaderboardState(
      ranking: LeaderboardRanking.streak,
      loading: false,
      entries: [],
      self: null,
      generatedAtUtc: null,
      fetchedAtUtc: null,
      bannerMessage: null,
      errorMessage: null,
    );
  }

  final LeaderboardRanking ranking;
  final bool loading;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? self;
  final DateTime? generatedAtUtc;
  final DateTime? fetchedAtUtc;
  final String? bannerMessage;
  final String? errorMessage;

  LeaderboardState copyWith({
    LeaderboardRanking? ranking,
    bool? loading,
    List<LeaderboardEntry>? entries,
    LeaderboardEntry? self,
    DateTime? generatedAtUtc,
    DateTime? fetchedAtUtc,
    String? bannerMessage,
    String? errorMessage,
  }) {
    return LeaderboardState(
      ranking: ranking ?? this.ranking,
      loading: loading ?? this.loading,
      entries: entries ?? this.entries,
      self: self ?? this.self,
      generatedAtUtc: generatedAtUtc ?? this.generatedAtUtc,
      fetchedAtUtc: fetchedAtUtc ?? this.fetchedAtUtc,
      bannerMessage: bannerMessage,
      errorMessage: errorMessage,
    );
  }
}

