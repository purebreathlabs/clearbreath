import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/features/home/domain/recommendation_engine.dart';
import 'package:clearbreath/features/home/presentation/home_screen.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_answers.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_answers_provider.dart';
import 'package:clearbreath/features/stats/domain/stats_engine.dart';
import 'package:clearbreath/features/stats/domain/stats_snapshot.dart';
import 'package:clearbreath/features/stats/domain/weekly_minutes_provider.dart';
import 'package:clearbreath/features/techniques/domain/favorites_provider.dart';
import 'package:clearbreath/features/techniques/domain/technique.dart';
import 'package:clearbreath/features/techniques/domain/technique_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Technique buildTechnique(String id) {
    return Technique(
      id: id,
      name: 'Box',
      shortDescription: 'A balanced four-part breath.',
      animationMode: AnimationMode.circle,
      goals: const {PrimaryGoal.calm},
      safety: const TechniqueSafety(requiresAck: false, title: '', body: ''),
      about: const TechniqueAbout(
        what: '',
        how: '',
        bestTime: '',
        benefits: '',
        warnings: '',
      ),
      presets: {
        'beginner': PhasePreset(
          id: 'beginner',
          label: 'Beginner',
          inhaleMs: 4000,
          holdMs: 0,
          exhaleMs: 6000,
          holdAfterExhaleMs: 0,
          recommendedDurationsMinutes: const [2, 5, 10, 20],
        ),
      },
    );
  }

  testWidgets('renders recommendation card and favorites', (tester) async {
    final technique = buildTechnique('box');
    final preset = technique.presets['beginner']!;
    final rec = Recommendation(
      techniqueId: technique.id,
      presetId: 'beginner',
      rationale: 'Test rationale',
      technique: technique,
      preset: preset,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingAnswersProvider.overrideWith(
            (ref) async => OnboardingAnswers.defaults().copyWith(
              displayName: 'Rahul',
              sessionLengthMinutes: 5,
            ),
          ),
          dailyRecommendationProvider.overrideWith((ref) async => rec),
          favoriteTechniquesProvider.overrideWith((ref) async => [technique]),
          localStatsProvider.overrideWith((ref) async => StatsSnapshot.empty()),
          weeklyMinutesProvider.overrideWith(
            (ref) async => const [0, 1, 2, 3, 4, 5, 6],
          ),
        ],
        child: MaterialApp(theme: AppTheme.dark(), home: const HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Today’s practice'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Start session'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
