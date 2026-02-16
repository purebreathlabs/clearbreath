import 'package:clearbreath/app.dart';
import 'package:clearbreath/features/auth/domain/auth_state.dart';
import 'package:clearbreath/features/auth/domain/auth_state_provider.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('leaderboard unlocks when signed in', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(() => _SignedInAuthStateController()),
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

    await tester.tap(find.text('Leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Leaderboard is locked'), findsNothing);
    expect(
      find.byKey(const Key('leaderboard_placeholder_title')),
      findsOneWidget,
    );
  });
}

class _SignedInAuthStateController extends AuthStateController {
  @override
  AuthState build() => const AuthStateSignedIn(userId: 'test-user');
}
