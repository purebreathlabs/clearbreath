import 'dart:math';

const int xpPerFullMinute = 10;
const int dailyOpenXP = 5;
const double endedEarlyPenalty = 0.5;
const int dailyPracticeXPCap = 300;
const double maxStreakMultiplier = 3.0;
const int curveVersion = 2;
const double levelCurveScale = 10.0;
const int maxLevel = 999;

final List<int> _thresholds = _buildThresholds();

List<int> _buildThresholds() {
  final t = List<int>.filled(maxLevel + 2, 0);
  var cumulative = 0;
  for (var k = 0; k <= maxLevel; k++) {
    final xpForLevel = ((2.0 + 0.05 * k + 0.0001 * k * k) * levelCurveScale)
        .floor();
    cumulative += xpForLevel;
    t[k + 1] = cumulative;
  }
  return t;
}

int levelFromTotalXP(int totalXP) {
  var lo = 0;
  var hi = _thresholds.length - 1;
  while (lo < hi) {
    final mid = (lo + hi + 1) ~/ 2;
    if (_thresholds[mid] <= totalXP) {
      lo = mid;
    } else {
      hi = mid - 1;
    }
  }
  return min(lo, maxLevel);
}

int cumulativeXPForLevel(int level) {
  if (level < 0) return 0;
  if (level >= _thresholds.length) return _thresholds.last;
  return _thresholds[level];
}

int xpForNextLevel(int level) {
  if (level < 0 || level + 1 >= _thresholds.length) return 0;
  return _thresholds[level + 1] - _thresholds[level];
}

double streakMultiplier(int streakDays) {
  return min(1.0 + 0.1 * streakDays, maxStreakMultiplier);
}

String presetForLevel(int level) {
  if (level < 15) return 'beginner';
  if (level < 50) return 'intermediate';
  return 'advanced';
}

int durationForLevel(int level) {
  if (level < 10) return 2;
  if (level < 30) return 5;
  if (level < 60) return 10;
  if (level < 100) return 15;
  return 20;
}

int computeSessionXP({
  required int durationSeconds,
  required bool endedEarly,
  required int streakDays,
}) {
  var baseMinutes = durationSeconds ~/ 60;
  if (endedEarly) {
    baseMinutes = (baseMinutes * endedEarlyPenalty).floor();
  }
  final baseXP = baseMinutes * xpPerFullMinute;
  if (baseXP <= 0) return 0;
  final mult = streakMultiplier(streakDays);
  return (baseXP * mult).floor();
}
