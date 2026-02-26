import 'package:flutter_test/flutter_test.dart';

import 'package:clearbreath/features/xp/domain/xp_engine.dart';

void main() {
  group('levelFromTotalXP', () {
    test('0 XP is level 0', () {
      expect(levelFromTotalXP(0), 0);
    });

    test('1 XP is still level 0', () {
      expect(levelFromTotalXP(1), 0);
    });

    test('2 XP is level 1', () {
      expect(levelFromTotalXP(2), 1);
    });

    test('very large XP caps at maxLevel', () {
      expect(levelFromTotalXP(999999), maxLevel);
    });
  });

  group('cumulativeXPForLevel', () {
    test('level 0 is 0 cumulative', () {
      expect(cumulativeXPForLevel(0), 0);
    });

    test('level 1 is 2 cumulative', () {
      expect(cumulativeXPForLevel(1), 2);
    });

    test('negative level returns 0', () {
      expect(cumulativeXPForLevel(-1), 0);
    });
  });

  group('xpForNextLevel', () {
    test('level 0 needs 2 XP', () {
      expect(xpForNextLevel(0), 2);
    });

    test('negative level returns 0', () {
      expect(xpForNextLevel(-1), 0);
    });
  });

  group('streakMultiplier', () {
    test('0 days = 1.0x', () {
      expect(streakMultiplier(0), 1.0);
    });

    test('1 day = 1.1x', () {
      expect(streakMultiplier(1), closeTo(1.1, 0.001));
    });

    test('10 days = 2.0x', () {
      expect(streakMultiplier(10), closeTo(2.0, 0.001));
    });

    test('20 days = 3.0x (cap)', () {
      expect(streakMultiplier(20), 3.0);
    });

    test('25 days still capped at 3.0x', () {
      expect(streakMultiplier(25), 3.0);
    });
  });

  group('presetForLevel', () {
    test('level 0 = beginner', () {
      expect(presetForLevel(0), 'beginner');
    });

    test('level 14 = beginner', () {
      expect(presetForLevel(14), 'beginner');
    });

    test('level 15 = intermediate', () {
      expect(presetForLevel(15), 'intermediate');
    });

    test('level 49 = intermediate', () {
      expect(presetForLevel(49), 'intermediate');
    });

    test('level 50 = advanced', () {
      expect(presetForLevel(50), 'advanced');
    });
  });

  group('durationForLevel', () {
    test('level 0 = 2 min', () {
      expect(durationForLevel(0), 2);
    });

    test('level 9 = 2 min', () {
      expect(durationForLevel(9), 2);
    });

    test('level 10 = 5 min', () {
      expect(durationForLevel(10), 5);
    });

    test('level 29 = 5 min', () {
      expect(durationForLevel(29), 5);
    });

    test('level 30 = 10 min', () {
      expect(durationForLevel(30), 10);
    });

    test('level 59 = 10 min', () {
      expect(durationForLevel(59), 10);
    });

    test('level 60 = 15 min', () {
      expect(durationForLevel(60), 15);
    });

    test('level 99 = 15 min', () {
      expect(durationForLevel(99), 15);
    });

    test('level 100 = 20 min', () {
      expect(durationForLevel(100), 20);
    });
  });

  group('computeSessionXP', () {
    test('5 min session = 50 XP (no streak)', () {
      expect(
        computeSessionXP(
          durationSeconds: 300,
          endedEarly: false,
          streakDays: 0,
        ),
        50,
      );
    });

    test('ended early 5 min = 20 XP', () {
      expect(
        computeSessionXP(durationSeconds: 300, endedEarly: true, streakDays: 0),
        20,
      );
    });

    test('sub-minute session = 0 XP', () {
      expect(
        computeSessionXP(durationSeconds: 50, endedEarly: false, streakDays: 0),
        0,
      );
    });

    test('10 day streak = 2.0x', () {
      expect(
        computeSessionXP(
          durationSeconds: 300,
          endedEarly: false,
          streakDays: 10,
        ),
        100,
      );
    });

    test('25 day streak = 3.0x (capped)', () {
      expect(
        computeSessionXP(
          durationSeconds: 300,
          endedEarly: false,
          streakDays: 25,
        ),
        150,
      );
    });

    test('ended early 10s session = 0 XP', () {
      expect(
        computeSessionXP(durationSeconds: 10, endedEarly: true, streakDays: 0),
        0,
      );
    });
  });
}
