import 'package:flutter/foundation.dart';

@immutable
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.displayNameOrInitials,
    required this.avatarSeed,
    required this.metricValue,
    this.userId,
  });

  final int? rank;
  final String displayNameOrInitials;
  final String avatarSeed;
  final int metricValue;
  final String? userId;
}

