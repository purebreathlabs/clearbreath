import 'package:clearbreath/app.dart';
import 'package:clearbreath/core/router/app_router.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('deep link cannot bypass onboarding', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appInitialLocationProvider.overrideWithValue('/leaderboard'),
        ],
        child: const ClearBreathApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Meet ClearBreath'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Your experience level'), findsOneWidget);

    await tester.tap(find.text('Skip setup'));
    await tester.pump();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Your experience level'), findsNothing);
    expect(find.text('Leaderboard is locked'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
