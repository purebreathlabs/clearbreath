import 'package:clearbreath/core/database/app_database.dart';
import 'package:clearbreath/core/network/models/user_models.dart';
import 'package:clearbreath/core/theme/app_theme.dart';
import 'package:clearbreath/core/theme/theme_extensions.dart';
import 'package:clearbreath/features/auth/domain/auth_controller.dart';
import 'package:clearbreath/features/auth/domain/auth_state.dart';
import 'package:clearbreath/features/auth/domain/auth_state_provider.dart';
import 'package:clearbreath/features/onboarding/domain/onboarding_answers.dart';
import 'package:clearbreath/features/profile/presentation/profile_screen.dart';
import 'package:clearbreath/features/stats/domain/stats_engine.dart';
import 'package:clearbreath/features/stats/domain/stats_snapshot.dart';
import 'package:clearbreath/features/stats/domain/weekly_minutes_provider.dart';
import 'package:clearbreath/features/sync/domain/merged_stats_provider.dart';
import 'package:clearbreath/features/techniques/data/technique_repository.dart';
import 'package:clearbreath/features/techniques/domain/technique.dart';
import 'package:clearbreath/features/techniques/domain/technique_preset.dart';
import 'package:clearbreath/features/xp/domain/xp_provider.dart';
import 'package:clearbreath/features/xp/domain/xp_state.dart';
import 'package:clearbreath/shared/providers/preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const prefs = Preference(
    id: 1,
    introComplete: true,
    onboardingComplete: true,
    experienceLevel: 'beginner',
    primaryGoal: 'calm',
    primaryGoalsJson: '["calm"]',
    practiceWindow: 'morning',
    practiceWindowsJson: '["morning"]',
    sessionLengthMinutes: 5,
    hapticsEnabled: true,
    keepScreenAwake: true,
    reminderTimeMinutes: 22 * 60,
    reminderEnabled: true,
    streakWarningEnabled: true,
    firstSessionCompleted: false,
    notificationPermissionAsked: false,
    displayName: 'Rahul',
    guestUsername: 'Rahul',
  );

  final snapshot = StatsSnapshot(
    currentStreakDays: 3,
    longestStreakDays: 5,
    practiceDaysAllTime: 0,
    minutesThisWeek: 12,
    minutesAllTime: 34,
    sessionsAllTime: 7,
    minutesByTechnique: const {'box': 12},
    longestSessionMinutes: 10,
    favoriteTechniqueId: 'box',
    totalBreathsEstimated: 123,
    updatedAt: DateTime.utc(2026, 2, 21),
  );

  final technique = Technique(
    id: 'box',
    name: 'Box',
    shortDescription: 'Box breathing.',
    animationMode: AnimationMode.circle,
    goals: const {PrimaryGoal.focus},
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
        recommendedDurationsMinutes: const [2, 5, 10, 20],
        inhaleMs: 4000,
        holdMs: 4000,
        exhaleMs: 4000,
        holdAfterExhaleMs: 4000,
      ),
    },
  );

  testWidgets('renders stats and guest sign-in CTA', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesProvider.overrideWith(
            (ref) => Stream<Preference?>.value(prefs),
          ),
          localStatsProvider.overrideWith((ref) async => snapshot),
          weeklyMinutesProvider.overrideWith(
            (ref, weekOffset) async => const [0, 1, 2, 3, 4, 5, 6],
          ),
          allTechniquesProvider.overrideWith((ref) async => [technique]),
        ],
        child: MaterialApp(theme: AppTheme.dark(), home: const ProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Rahul'), findsOneWidget);
    expect(
      find.text('Create an account to sync sessions across devices.'),
      findsOneWidget,
    );
    expect(find.text('Sign in'), findsOneWidget);

    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('Minutes'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.text('This week'), findsNWidgets(2));
    expect(find.text('By technique'), findsOneWidget);
    expect(find.text('Box'), findsOneWidget);
    expect(find.text('12m'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('edit name dialog uses near-full width on phones', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(() => _SignedInAuthController()),
          preferencesProvider.overrideWith(
            (ref) => Stream<Preference?>.value(prefs),
          ),
          mergedStatsProvider.overrideWith((ref) async => snapshot),
          mergedXPProvider.overrideWith((ref) async => XPState.empty()),
          weeklyMinutesProvider.overrideWith(
            (ref, weekOffset) async => const [0, 1, 2, 3, 4, 5, 6],
          ),
          allTechniquesProvider.overrideWith((ref) async => [technique]),
        ],
        child: MaterialApp(theme: AppTheme.dark(), home: const ProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit username'));
    await tester.pumpAndSettle();

    final dialogBox = find.byKey(const Key('edit_username_dialog'));
    expect(dialogBox, findsOneWidget);

    final context = tester.element(dialogBox);
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final screenWidth = tester.binding.renderViews.single.size.width;
    final expectedDialogWidth = (screenWidth - spacing.sm * 2).clamp(
      0.0,
      420.0,
    );

    final size = tester.getSize(dialogBox);
    expect(size.width, closeTo(expectedDialogWidth, 0.1));
  });
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
