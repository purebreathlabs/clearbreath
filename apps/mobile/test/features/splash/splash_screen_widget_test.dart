import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject() {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: const SplashScreen(from: '/home'),
      ),
    );
  }

  double extractScale(WidgetTester tester) {
    final finder = find.descendant(
      of: find.byType(SplashScreen),
      matching: find.byType(Transform),
    );
    final transform = tester.widget<Transform>(finder.first);
    return transform.transform.getMaxScaleOnAxis();
  }

  testWidgets('logo scale is monotonic non-decreasing', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    final s0 = extractScale(tester);

    await tester.pump(const Duration(milliseconds: 400));
    final s400 = extractScale(tester);

    await tester.pump(const Duration(milliseconds: 500));
    final s900 = extractScale(tester);

    await tester.pump(const Duration(milliseconds: 800));
    final s1700 = extractScale(tester);

    expect(s400, greaterThanOrEqualTo(s0));
    expect(s900, greaterThanOrEqualTo(s400));
    expect(s1700, greaterThanOrEqualTo(s900));
    expect(s1700, closeTo(1.0, 0.01));
  });

  testWidgets('tagline is not shown on splash', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Breathe with intention.'), findsNothing);
    expect(find.text('ClearBreath'), findsOneWidget);
  });
}
