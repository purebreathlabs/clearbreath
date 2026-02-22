import 'package:clearbreath/features/home/domain/recommendation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('day part boundaries follow spec', () {
    expect(currentDayPart(DateTime(2026, 2, 22, 4, 59)), DayPart.night);
    expect(currentDayPart(DateTime(2026, 2, 22, 5, 0)), DayPart.morning);
    expect(currentDayPart(DateTime(2026, 2, 22, 10, 59)), DayPart.morning);
    expect(currentDayPart(DateTime(2026, 2, 22, 11, 0)), DayPart.afternoon);
    expect(currentDayPart(DateTime(2026, 2, 22, 16, 59)), DayPart.afternoon);
    expect(currentDayPart(DateTime(2026, 2, 22, 17, 0)), DayPart.evening);
    expect(currentDayPart(DateTime(2026, 2, 22, 21, 59)), DayPart.evening);
    expect(currentDayPart(DateTime(2026, 2, 22, 22, 0)), DayPart.night);
    expect(currentDayPart(DateTime(2026, 2, 22, 0, 0)), DayPart.night);
  });
}
