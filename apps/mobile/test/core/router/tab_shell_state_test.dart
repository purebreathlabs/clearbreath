import 'package:clearbreath/app.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_gate.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('tab branches preserve navigation stack', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingGateProvider.overrideWith((ref) {
            final repository = ref.watch(onboardingRepositoryProvider);
            final gate = OnboardingGate(
              repository,
              initialStatus: OnboardingStatus.complete,
              loadOnInit: false,
            );
            ref.onDispose(gate.dispose);
            return gate;
          }),
        ],
        child: const ClearBreathApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Design System'));
    await tester.pumpAndSettle();
    expect(find.text('Design System'), findsOneWidget);

    await tester.tap(find.text('Techniques'));
    await tester.pumpAndSettle();
    expect(find.text('Design System'), findsNothing);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Design System'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
