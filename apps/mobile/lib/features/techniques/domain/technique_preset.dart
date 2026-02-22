import 'package:flutter/foundation.dart';

@immutable
sealed class TechniquePreset {
  TechniquePreset({
    required this.id,
    required this.label,
    required List<int> recommendedDurationsMinutes,
  }) : recommendedDurationsMinutes = List.unmodifiable(recommendedDurationsMinutes);

  final String id;
  final String label;
  final List<int> recommendedDurationsMinutes;
}

final class PhasePreset extends TechniquePreset {
  PhasePreset({
    required super.id,
    required super.label,
    required super.recommendedDurationsMinutes,
    required this.inhaleMs,
    required this.holdMs,
    required this.exhaleMs,
    required this.holdAfterExhaleMs,
  });

  final int inhaleMs;
  final int holdMs;
  final int exhaleMs;
  final int holdAfterExhaleMs;
}

final class BpmRoundsPreset extends TechniquePreset {
  BpmRoundsPreset({
    required super.id,
    required super.label,
    required super.recommendedDurationsMinutes,
    required this.bpm,
    required this.rounds,
    required this.roundSeconds,
    required this.restSeconds,
  });

  final int bpm;
  final int rounds;
  final int roundSeconds;
  final int restSeconds;
}
