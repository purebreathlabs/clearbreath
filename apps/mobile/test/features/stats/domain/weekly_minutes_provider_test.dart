import 'package:clearbreath/features/stats/domain/weekly_minutes_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('weekTitle', () {
    test('returns This week for offset 0', () {
      expect(weekTitle(0), 'This week');
    });

    test('returns Last week for offset -1', () {
      expect(weekTitle(-1), 'Last week');
    });

    test('returns date range for offset -2 and below', () {
      final title = weekTitle(-2);
      expect(title, contains('\u2013'));
      expect(title, isNot('This week'));
      expect(title, isNot('Last week'));
    });

    test('date range format matches abbreviated month and day', () {
      final title = weekTitle(-3);
      expect(RegExp(r'^[A-Z][a-z]{2} \d+ .+ [A-Z][a-z]{2} \d+$').hasMatch(title), isTrue);
    });
  });

  group('weekStartForOffset', () {
    test('offset 0 returns a Monday', () {
      final start = weekStartForOffset(0);
      expect(start.weekday, DateTime.monday);
    });

    test('offset -1 is 7 days before offset 0', () {
      final current = weekStartForOffset(0);
      final previous = weekStartForOffset(-1);
      expect(current.difference(previous).inDays, 7);
    });

    test('offset -4 is 28 days before offset 0', () {
      final current = weekStartForOffset(0);
      final past = weekStartForOffset(-4);
      expect(current.difference(past).inDays, 28);
    });

    test('all offsets return Mondays', () {
      for (var i = 0; i >= -10; i--) {
        expect(weekStartForOffset(i).weekday, DateTime.monday);
      }
    });
  });
}
