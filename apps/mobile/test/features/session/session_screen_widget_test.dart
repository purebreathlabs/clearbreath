import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_answers.dart';
import 'package:clearbreath/features/session/domain/active_session_config.dart';
import 'package:clearbreath/features/session/domain/session_tick_source.dart';
import 'package:clearbreath/features/session/presentation/session_screen.dart';
import 'package:clearbreath/features/session/presentation/widgets/alternate_nostril_indicator.dart';
import 'package:clearbreath/features/session/presentation/widgets/breathing_circle.dart';
import 'package:clearbreath/features/session/presentation/widgets/metronome_pulse.dart';
import 'package:clearbreath/features/techniques/data/technique_repository.dart';
import 'package:clearbreath/features/techniques/domain/technique.dart';
import 'package:clearbreath/features/techniques/domain/technique_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
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
      goals: const {PrimaryGoal.focus},
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
      },
    );

    final kapalbhati = Technique(
      id: 'kapalbhati',
      name: 'Kapalbhati',
      shortDescription: 'Fast rounds with rests.',
      animationMode: AnimationMode.metronome,
      goals: const {PrimaryGoal.energy},
      safety: const TechniqueSafety(requiresAck: false, title: '', body: ''),
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
          roundSeconds: 2,
          restSeconds: 1,
        ),
      },
    );

    final anulomVilom = Technique(
      id: 'anulom_vilom',
      name: 'Anulom Vilom',
      shortDescription: 'Alternate nostrils.',
      animationMode: AnimationMode.alternateNostril,
      goals: const {PrimaryGoal.calm},
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
          inhaleMs: 1000,
          holdMs: 0,
          exhaleMs: 1000,
          holdAfterExhaleMs: 0,
        ),
      },
    );

    return [box, kapalbhati, anulomVilom];
  }

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/session',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/session',
          builder: (context, state) => const SessionScreen(),
        ),
      ],
    );
  }

  testWidgets('renders breathing circle by default', (tester) async {
    final techniques = buildTechniques();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          techniqueRepositoryProvider.overrideWithValue(
            TestTechniqueRepository(techniques),
          ),
          sessionTickSourceProvider.overrideWithValue(
            FixedSessionTickSource(const Duration(milliseconds: 50)),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: buildRouter(),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(BreathingCircle), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('renders metronome pulse for metronome technique', (
    tester,
  ) async {
    final techniques = buildTechniques();
    final technique = techniques.firstWhere((t) => t.id == 'kapalbhati');
    final preset = technique.presets['beginner']!;

    final config = ActiveSessionConfig(
      technique: technique,
      preset: preset,
      presetId: 'beginner',
      durationLimitSeconds: 5 * 60,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          techniqueRepositoryProvider.overrideWithValue(
            TestTechniqueRepository(techniques),
          ),
          sessionTickSourceProvider.overrideWithValue(
            FixedSessionTickSource(const Duration(milliseconds: 50)),
          ),
          activeSessionConfigProvider.overrideWith(
            () => _TestActiveSessionConfigController(config),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: buildRouter(),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(MetronomePulse), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('renders alternate nostril indicator for anulom vilom', (
    tester,
  ) async {
    final techniques = buildTechniques();
    final technique = techniques.firstWhere((t) => t.id == 'anulom_vilom');
    final preset = technique.presets['beginner']!;

    final config = ActiveSessionConfig(
      technique: technique,
      preset: preset,
      presetId: 'beginner',
      durationLimitSeconds: 5 * 60,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          techniqueRepositoryProvider.overrideWithValue(
            TestTechniqueRepository(techniques),
          ),
          sessionTickSourceProvider.overrideWithValue(
            FixedSessionTickSource(const Duration(milliseconds: 50)),
          ),
          activeSessionConfigProvider.overrideWith(
            () => _TestActiveSessionConfigController(config),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: buildRouter(),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(AlternateNostrilIndicator), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('pause resume and stop update the screen', (tester) async {
    final techniques = buildTechniques();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          techniqueRepositoryProvider.overrideWithValue(
            TestTechniqueRepository(techniques),
          ),
          sessionTickSourceProvider.overrideWithValue(
            FixedSessionTickSource(const Duration(milliseconds: 50)),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: buildRouter(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('INHALE'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);

    await tester.tap(find.text('Pause'));
    await tester.pump();

    expect(find.text('PAUSED'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('PAUSED'), findsOneWidget);

    await tester.tap(find.text('Resume'));
    await tester.pump();
    expect(find.text('PAUSED'), findsNothing);

    await tester.tap(find.text('Stop'));
    await tester.pump();
    expect(find.text('End session early?'), findsOneWidget);

    await tester.tap(find.text('End'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('Home'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

class TestTechniqueRepository extends TechniqueRepository {
  TestTechniqueRepository(this._techniques);

  final List<Technique> _techniques;

  @override
  Future<List<Technique>> all() async => _techniques;
}

class _TestActiveSessionConfigController extends ActiveSessionConfigController {
  _TestActiveSessionConfigController(this._config);

  final ActiveSessionConfig _config;

  @override
  ActiveSessionConfig? build() => _config;
}
