import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/core/network/models/user_models.dart';
import 'package:clearbreath/features/auth/domain/auth_controller.dart';
import 'package:clearbreath/features/auth/domain/auth_state.dart';
import 'package:clearbreath/features/auth/domain/auth_state_provider.dart';
import 'package:clearbreath/features/home/domain/recommendation_engine.dart';
import 'package:clearbreath/features/home/presentation/home_screen.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_answers.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_answers_provider.dart';
import 'package:clearbreath/features/stats/domain/stats_engine.dart';
import 'package:clearbreath/features/stats/domain/stats_snapshot.dart';
import 'package:clearbreath/features/stats/domain/weekly_minutes_provider.dart';
import 'package:clearbreath/features/sync/domain/merged_stats_provider.dart';
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
          mergedWeeklyMinutesProvider.overrideWith(
            (ref, weekOffset) async => const [0, 1, 2, 3, 4, 5, 6],
          ),
        ],
        child: MaterialApp(theme: AppTheme.dark(), home: const HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('practice'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Start session'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('shows signed-in display name in greeting', (tester) async {
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
          authStateProvider.overrideWith(() => _SignedInAuthController()),
          dailyRecommendationProvider.overrideWith((ref) async => rec),
          favoriteTechniquesProvider.overrideWith((ref) async => [technique]),
          mergedStatsProvider.overrideWith(
            (ref) async => StatsSnapshot.empty(),
          ),
          mergedWeeklyMinutesProvider.overrideWith(
            (ref, weekOffset) async => const [0, 0, 0, 0, 0, 0, 0],
          ),
        ],
        child: MaterialApp(theme: AppTheme.dark(), home: const HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Rahul'), findsOneWidget);
  });

  testWidgets(
    'uses merged stats snapshot for current streak and weekly summary',
    (tester) async {
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
            dailyRecommendationProvider.overrideWith((ref) async => rec),
            favoriteTechniquesProvider.overrideWith((ref) async => [technique]),
            mergedStatsProvider.overrideWith(
              (ref) async => StatsSnapshot(
                currentStreakDays: 1,
                longestStreakDays: 1,
                practiceDaysAllTime: 1,
                minutesThisWeek: 5,
                minutesAllTime: 5,
                sessionsAllTime: 1,
                minutesByTechnique: const {'box': 5},
                weeklyMinutesByDay: const [5, 0, 0, 0, 0, 0, 0],
                longestSessionMinutes: 5,
                favoriteTechniqueId: 'box',
                totalBreathsEstimated: 30,
                updatedAt: DateTime.utc(2026, 3, 6),
              ),
            ),
          ],
          child: MaterialApp(theme: AppTheme.dark(), home: const HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('1'), findsWidgets);
      expect(find.text('5'), findsWidgets);
      expect(find.text('days'), findsOneWidget);
      expect(find.text('min'), findsOneWidget);
    },
  );
}

class _SignedInAuthController extends AuthController {
  @override
  AuthState build() {
    return AuthStateSignedIn(
      profile: UserProfile(
        id: 'user-a',
        username: 'rahul',
        name: 'Rahul',
        avatarSeed: 'seed-a',
        leaderboardOptIn: true,
        createdAtUtc: DateTime.utc(2026, 2, 22),
        timezoneOffsetMinutesLatest: 0,
      ),
    );
  }
}
