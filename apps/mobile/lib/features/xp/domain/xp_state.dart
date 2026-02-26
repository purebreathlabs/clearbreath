import 'package:flutter/foundation.dart';

import 'xp_engine.dart' as engine;

@immutable
class XPState {
  const XPState({
    required this.totalXP,
    required this.currentLevel,
    required this.xpForCurrentLevel,
    required this.xpForNextLevel,
    required this.xpProgressInLevel,
    required this.currentStreakDays,
    required this.practiceDaysAllTime,
    required this.presetId,
    required this.durationMinutes,
  });

  factory XPState.fromTotalXP({
    required int totalXP,
    required int currentStreakDays,
    required int practiceDaysAllTime,
  }) {
    final level = engine.levelFromTotalXP(totalXP);
    final cumCurrent = engine.cumulativeXPForLevel(level);
    final nextLevel = engine.xpForNextLevel(level);
    return XPState(
      totalXP: totalXP,
      currentLevel: level,
      xpForCurrentLevel: cumCurrent,
      xpForNextLevel: nextLevel,
      xpProgressInLevel: totalXP - cumCurrent,
      currentStreakDays: currentStreakDays,
      practiceDaysAllTime: practiceDaysAllTime,
      presetId: engine.presetForPracticeDays(practiceDaysAllTime),
      durationMinutes: engine.durationForPracticeDays(practiceDaysAllTime),
    );
  }

  factory XPState.empty() => XPState.fromTotalXP(
    totalXP: 0,
    currentStreakDays: 0,
    practiceDaysAllTime: 0,
  );

  final int totalXP;
  final int currentLevel;
  final int xpForCurrentLevel;
  final int xpForNextLevel;
  final int xpProgressInLevel;
  final int currentStreakDays;
  final int practiceDaysAllTime;
  final String presetId;
  final int durationMinutes;

  double get progressFraction {
    if (xpForNextLevel <= 0) return 1.0;
    return (xpProgressInLevel / xpForNextLevel).clamp(0.0, 1.0);
  }

  double get currentMultiplier => engine.streakMultiplier(currentStreakDays);
}
