import 'package:clearbreath/app.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_gate.dart';
import 'package:clearbreath/features/profile/presentation/profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('profile tab renders placeholder screen', (tester) async {
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

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
