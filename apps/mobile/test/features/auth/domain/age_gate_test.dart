import 'package:clearbreath/features/auth/domain/age_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('age gate: 12 fails and 13 passes', () {
    final now = DateTime.utc(2026, 2, 22);

    expect(isEligible(2014, now), isFalse);
    expect(isEligible(2013, now), isTrue);
  });
}
