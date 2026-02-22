import 'package:clearbreath/features/stats/domain/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty data yields zero', () {
    expect(currentStreak(const {}, DateTime.utc(2026, 2, 21, 12)), equals(0));
    expect(longestStreak(const {}), equals(0));
  });

  test('2-minute threshold', () {
    final day = DateTime.utc(2026, 2, 21);
    expect(currentStreak({day: 1}, DateTime.utc(2026, 2, 21, 12)), equals(0));
    expect(currentStreak({day: 2}, DateTime.utc(2026, 2, 21, 12)), equals(1));
  });

  test('yesterday counts when today is under threshold', () {
    final yesterday = DateTime.utc(2026, 2, 20);
    final today = DateTime.utc(2026, 2, 21, 8);
    expect(currentStreak({yesterday: 2}, today), equals(1));
  });

  test('consecutive qualifying days count as streak', () {
    final d1 = DateTime.utc(2026, 2, 19);
    final d2 = DateTime.utc(2026, 2, 20);
    final d3 = DateTime.utc(2026, 2, 21);
    final minutes = {d1: 2, d2: 3, d3: 2};
    expect(currentStreak(minutes, DateTime.utc(2026, 2, 21, 18)), equals(3));
    expect(longestStreak(minutes), equals(3));
  });

  test('gap breaks streak', () {
    final d1 = DateTime.utc(2026, 2, 19);
    final d3 = DateTime.utc(2026, 2, 21);
    final minutes = {d1: 2, d3: 2};
    expect(currentStreak(minutes, DateTime.utc(2026, 2, 21, 12)), equals(1));
    expect(longestStreak(minutes), equals(1));
  });

  test('time component is ignored for day keys', () {
    final day = DateTime.utc(2026, 2, 21);
    final minutes = {day: 2};
    expect(currentStreak(minutes, DateTime.utc(2026, 2, 21, 23, 59)), equals(1));
  });
}

