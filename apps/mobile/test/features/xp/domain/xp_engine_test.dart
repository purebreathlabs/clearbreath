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

    test('19 XP is still level 0', () {
      expect(levelFromTotalXP(19), 0);
    });

    test('20 XP is level 1', () {
      expect(levelFromTotalXP(20), 1);
    });

    test('22 XP is level 1', () {
      expect(levelFromTotalXP(22), 1);
    });

    test('very large XP caps at maxLevel', () {
      expect(levelFromTotalXP(999999), maxLevel);
    });
  });

  group('cumulativeXPForLevel', () {
    test('level 0 is 0 cumulative', () {
      expect(cumulativeXPForLevel(0), 0);
    });

    test('level 1 is 20 cumulative', () {
      expect(cumulativeXPForLevel(1), 20);
    });

    test('negative level returns 0', () {
      expect(cumulativeXPForLevel(-1), 0);
    });
  });

  group('xpForNextLevel', () {
    test('level 0 needs 20 XP', () {
      expect(xpForNextLevel(0), 20);
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

  group('presetForPracticeDays', () {
    test('0 days = beginner', () {
      expect(presetForPracticeDays(0), 'beginner');
    });

    test('14 days = beginner', () {
      expect(presetForPracticeDays(14), 'beginner');
    });

    test('15 days = intermediate', () {
      expect(presetForPracticeDays(15), 'intermediate');
    });

    test('49 days = intermediate', () {
      expect(presetForPracticeDays(49), 'intermediate');
    });

    test('50 days = advanced', () {
      expect(presetForPracticeDays(50), 'advanced');
    });
  });

  group('durationForPracticeDays', () {
    test('0 days = 2 min', () {
      expect(durationForPracticeDays(0), 2);
    });

    test('6 days = 2 min', () {
      expect(durationForPracticeDays(6), 2);
    });

    test('7 days = 5 min', () {
      expect(durationForPracticeDays(7), 5);
    });

    test('29 days = 5 min', () {
      expect(durationForPracticeDays(29), 5);
    });

    test('30 days = 10 min', () {
      expect(durationForPracticeDays(30), 10);
    });

    test('59 days = 10 min', () {
      expect(durationForPracticeDays(59), 10);
    });

    test('60 days = 15 min', () {
      expect(durationForPracticeDays(60), 15);
    });

    test('99 days = 15 min', () {
      expect(durationForPracticeDays(99), 15);
    });

    test('100 days = 20 min', () {
      expect(durationForPracticeDays(100), 20);
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
