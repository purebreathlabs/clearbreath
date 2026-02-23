import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/techniques/presentation/techniques_screen.dart';
import 'package:clearbreath/features/techniques/presentation/widgets/technique_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('grid renders 9 technique cards', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const TechniquesScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final grid = find.byKey(const Key('techniques_grid'));
    final scrollable = find
        .descendant(of: grid, matching: find.byType(Scrollable))
        .first;
    final ids = [
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
      final card = find.byKey(Key('technique_card_$id'));
      await tester.scrollUntilVisible(card, 500, scrollable: scrollable);
      expect(card, findsOneWidget);
    }

    expect(find.byType(TechniqueCard), findsWidgets);
  });

  testWidgets('search field and filter chips exist', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const TechniquesScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('techniques_search_field')), findsOneWidget);
    expect(find.byKey(const Key('filter_chip_all')), findsOneWidget);
    expect(find.byKey(const Key('filter_chip_calm')), findsOneWidget);
  });
}
