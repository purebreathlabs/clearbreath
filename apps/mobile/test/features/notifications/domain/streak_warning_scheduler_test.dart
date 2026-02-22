import 'package:clearbreath/features/notifications/domain/streak_warning_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns null when no streak', () {
    final now = DateTime(2026, 2, 22, 10);
    expect(nextStreakWarningTime(0, false, now), isNull);
  });

  test('returns null when already qualified today', () {
    final now = DateTime(2026, 2, 22, 10);
    expect(nextStreakWarningTime(3, true, now), isNull);
  });

  test('returns 22:00 when streak active and not qualified', () {
    final now = DateTime(2026, 2, 22, 10, 15);
    final next = nextStreakWarningTime(2, false, now);
    expect(next, DateTime(2026, 2, 22, 22, 0));
  });

  test('returns null when it is already 22:00', () {
    final now = DateTime(2026, 2, 22, 22, 0);
    expect(nextStreakWarningTime(2, false, now), isNull);
  });
}

