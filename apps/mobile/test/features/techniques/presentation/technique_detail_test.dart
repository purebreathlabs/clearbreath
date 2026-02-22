import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/session/domain/active_session_config.dart';
import 'package:clearbreath/features/techniques/data/technique_repository.dart';
import 'package:clearbreath/features/techniques/domain/technique.dart';
import 'package:clearbreath/features/techniques/domain/technique_preset.dart';
import 'package:clearbreath/features/techniques/presentation/technique_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    expect(finder, findsOneWidget);
  }

  List<Technique> buildTechniques() {
    final durations = [2, 5, 10, 20];

    PhasePreset phasePreset({
      required String id,
      required int inhaleMs,
      required int holdMs,
      required int exhaleMs,
      required int holdAfterExhaleMs,
    }) {
      return PhasePreset(
        id: id,
        label: id,
        inhaleMs: inhaleMs,
        holdMs: holdMs,
        exhaleMs: exhaleMs,
        holdAfterExhaleMs: holdAfterExhaleMs,
        recommendedDurationsMinutes: durations,
      );
    }

    BpmRoundsPreset roundsPreset({
      required String id,
      required int bpm,
      required int rounds,
      required int roundSeconds,
      required int restSeconds,
    }) {
      return BpmRoundsPreset(
        id: id,
        label: id,
        bpm: bpm,
        rounds: rounds,
        roundSeconds: roundSeconds,
        restSeconds: restSeconds,
        recommendedDurationsMinutes: durations,
      );
    }

    final box = Technique(
      id: 'box',
      name: 'Box',
      shortDescription: 'A balanced four-part breath.',
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
        'beginner': phasePreset(
          id: 'beginner',
          inhaleMs: 4000,
          holdMs: 4000,
          exhaleMs: 4000,
          holdAfterExhaleMs: 4000,
        ),
        'intermediate': phasePreset(
          id: 'intermediate',
          inhaleMs: 5000,
          holdMs: 5000,
          exhaleMs: 5000,
          holdAfterExhaleMs: 5000,
        ),
        'advanced': phasePreset(
          id: 'advanced',
          inhaleMs: 6000,
          holdMs: 6000,
          exhaleMs: 6000,
          holdAfterExhaleMs: 6000,
        ),
      },
    );

    final kapalbhati = Technique(
      id: 'kapalbhati',
      name: 'Kapalbhati',
      shortDescription: 'Fast rounds with rests.',
      animationMode: AnimationMode.metronome,
      safety: const TechniqueSafety(
        requiresAck: true,
        title: 'Kapalbhati safety',
        body: 'Body',
      ),
      about: const TechniqueAbout(
        what: 'What',
        how: 'How',
        bestTime: 'Best',
        benefits: 'Benefits',
        warnings: 'Warnings',
      ),
      presets: {
        'beginner': roundsPreset(
          id: 'beginner',
          bpm: 60,
          rounds: 3,
          roundSeconds: 30,
          restSeconds: 30,
        ),
        'intermediate': roundsPreset(
          id: 'intermediate',
          bpm: 80,
          rounds: 3,
          roundSeconds: 45,
          restSeconds: 30,
        ),
        'advanced': roundsPreset(
          id: 'advanced',
          bpm: 120,
          rounds: 3,
          roundSeconds: 60,
          restSeconds: 45,
        ),
      },
    );

    return [box, kapalbhati];
  }

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        techniqueRepositoryProvider.overrideWithValue(
          TestTechniqueRepository(buildTechniques()),
        ),
      ],
    );
  }

  testWidgets('preset selector updates session config', (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/techniques/box',
      routes: [
        GoRoute(
          path: '/techniques/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return TechniqueDetailScreen(techniqueId: id);
          },
        ),
        GoRoute(
          path: '/session',
          builder: (context, state) {
            return const Scaffold(body: Text('Session'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.dark(), routerConfig: router),
      ),
    );

    await pumpUntilFound(tester, find.text('Start Session'));

    await tester.tap(find.byKey(const Key('preset_advanced')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('duration_10')));
    await tester.pump();

    await tester.tap(find.text('Start Session'));
    await pumpUntilFound(tester, find.text('Session'));

    expect(find.text('Session'), findsOneWidget);
    final config = container.read(activeSessionConfigProvider);
    expect(config, isNotNull);
    expect(config!.technique.id, 'box');
    expect(config.presetId, 'advanced');
    expect(config.durationLimitSeconds, 10 * 60);
  });

  testWidgets('safety gate shows sheet for gated techniques', (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/techniques/kapalbhati',
      routes: [
        GoRoute(
          path: '/techniques/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return TechniqueDetailScreen(techniqueId: id);
          },
        ),
        GoRoute(
          path: '/session',
          builder: (context, state) {
            return const Scaffold(body: Text('Session'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.dark(), routerConfig: router),
      ),
    );

    await pumpUntilFound(tester, find.byType(TechniqueDetailScreen));
    await pumpUntilFound(tester, find.text('Start Session'));
    expect(find.text('Kapalbhati'), findsOneWidget);
    await tester.tap(find.text('Start Session'));
    await pumpUntilFound(tester, find.text('Kapalbhati safety'));
    await tester.pumpAndSettle();

    expect(find.text('Kapalbhati safety'), findsOneWidget);
    await tester.tap(find.text('I understand the risks'));
    await pumpUntilFound(tester, find.text('Session'));

    final config = container.read(activeSessionConfigProvider);
    expect(config, isNotNull);
    expect(config!.technique.id, 'kapalbhati');
    expect(config.presetId, 'beginner');
    expect(config.durationLimitSeconds, 5 * 60);
  });
}

class TestTechniqueRepository extends TechniqueRepository {
  TestTechniqueRepository(this._techniques);

  final List<Technique> _techniques;

  @override
  Future<List<Technique>> all() async => _techniques;
}
