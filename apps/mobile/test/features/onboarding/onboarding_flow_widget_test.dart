import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('onboarding follows step order and shows skip confirm', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const OnboardingScreen(from: '/home'),
        ),
      ),
    );

    expect(find.text('Your experience level'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Your primary goal'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Your experience level'), findsOneWidget);

    await tester.tap(find.text('Skip setup'));
    await tester.pump();
    expect(find.text('Skip setup?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Skip setup?'), findsNothing);
  });
}

