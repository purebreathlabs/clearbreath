import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/session/domain/local_session.dart';
import 'package:clearbreath/features/session/presentation/session_completion_screen.dart';
import 'package:clearbreath/features/techniques/data/technique_repository.dart';
import 'package:clearbreath/features/techniques/domain/technique.dart';
import 'package:clearbreath/features/techniques/domain/technique_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Technique buildTechnique() {
    return Technique(
      id: 'box',
      name: 'Box',
      shortDescription: 'Box breathing.',
      animationMode: AnimationMode.circle,
      safety: const TechniqueSafety(requiresAck: false, title: '', body: ''),
      about: const TechniqueAbout(
        what: 'What',
        how: 'How',
        bestTime: 'Best',
        benefits: 'Benefits',
        warnings: 'Warnings',
      ),
      presets: {
        'beginner': PhasePreset(
          id: 'beginner',
          label: 'Beginner',
          recommendedDurationsMinutes: const [2, 5, 10, 20],
          inhaleMs: 4000,
          holdMs: 4000,
          exhaleMs: 4000,
          holdAfterExhaleMs: 4000,
        ),
      },
    );
  }

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/session/complete',
          builder: (context, state) {
            final extra = state.extra;
            return SessionCompletionScreen(
              session: extra is LocalSession ? extra : null,
            );
          },
        ),
      ],
    );
  }

  testWidgets('shows metrics and done navigates home', (tester) async {
    final technique = buildTechnique();
    final session = LocalSession(
      clientSessionId: 's1',
      techniqueId: 'box',
      presetId: 'beginner',
      startedAtUtc: DateTime.utc(2026, 2, 20, 10),
      endedAtUtc: DateTime.utc(2026, 2, 20, 10, 5),
      timezoneOffsetMinutes: 0,
      durationSecondsActual: 300,
      breathsCompletedEstimated: 42,
      endedEarly: false,
      syncedToCloud: false,
      createdAt: DateTime.utc(2026, 2, 20, 10, 5),
    );

    final router = buildRouter();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          techniqueRepositoryProvider.overrideWithValue(
            _TestTechniqueRepository([technique]),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: router,
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);

    router.go('/session/complete', extra: session);
    await tester.pumpAndSettle();

    expect(find.text('Box'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('completion_minutes_tile')),
        matching: find.text('5'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('completion_breaths_tile')),
        matching: find.text('42'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });
}

class _TestTechniqueRepository extends TechniqueRepository {
  _TestTechniqueRepository(this._techniques);

  final List<Technique> _techniques;

  @override
  Future<List<Technique>> all() async => _techniques;
}

