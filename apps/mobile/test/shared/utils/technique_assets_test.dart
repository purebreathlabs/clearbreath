import 'package:clearbreath/shared/utils/technique_assets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all 9 technique IDs return non-null paths', () {
    const ids = [
      'box',
      'four_seven_eight',
      'anulom_vilom',
      'ujjayi',
      'bhramari',
      'hrv_resonance',
      'ultra_slow',
      'kapalbhati',
      'bhastrika',
    ];

    for (final id in ids) {
      final path = techniqueImageAsset(id);
      expect(path, isNotNull, reason: 'Expected non-null path for "$id"');
      expect(path, endsWith('.png'));
    }
  });

  test('unknown ID returns null', () {
    expect(techniqueImageAsset('unknown'), isNull);
    expect(techniqueImageAsset(''), isNull);
  });
}
