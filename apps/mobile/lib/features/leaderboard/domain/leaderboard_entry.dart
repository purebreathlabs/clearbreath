import 'package:flutter/foundation.dart';

@immutable
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.avatarSeed,
    required this.totalXp,
    required this.level,
    this.name,
    this.userId,
  });

  final int? rank;
  final String username;
  final String? name;
  final String avatarSeed;
  final int totalXp;
  final int level;
  final String? userId;

  String get displayLabel =>
      (name != null && name!.isNotEmpty) ? name! : username;

  String get subtitle => (name != null && name!.isNotEmpty) ? '@$username' : '';
}
