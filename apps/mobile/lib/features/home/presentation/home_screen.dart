import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../onboarding/domain/onboarding_answers.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/domain/auth_state_provider.dart';
import '../../session/domain/active_session_config.dart';
import '../../stats/domain/weekly_minutes_provider.dart';
import '../../sync/domain/merged_stats_provider.dart';
import '../../techniques/domain/favorites_provider.dart';
import '../../techniques/domain/safety_acknowledgement_repository.dart';
import '../../techniques/domain/technique.dart';
import '../../techniques/presentation/widgets/safety_warning_sheet.dart';
import '../../../shared/widgets/weekly_bar_chart.dart';
import '../../../shared/providers/preferences_provider.dart';
import '../domain/active_goal_provider.dart';
import '../domain/recommendation_engine.dart';
import 'widgets/favorites_row.dart';
import 'widgets/goal_shortcut_row.dart';
import 'widgets/streak_display.dart';
import 'widgets/todays_practice_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    void showMessage(String message) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: typography.bodyMedium.copyWith(color: colors.inverseText),
          ),
          backgroundColor: colors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(components.buttonRadius),
          ),
        ),
      );
    }

    final recommendation = ref.watch(dailyRecommendationProvider);
    final selectedGoal = _selectGoal(ref.watch(activeGoalProvider));
    final favorites = ref.watch(favoriteTechniquesProvider);
    final stats = ref.watch(mergedStatsProvider);
    final weeklyMinutes = ref.watch(weeklyMinutesProvider);

    final prefs = ref.watch(preferencesProvider);
    final row = prefs.asData?.value;
    final durationMinutes = row?.sessionLengthMinutes ?? 5;
    final localDisplayName = row?.displayName.trim() ?? '';
    final auth = ref.watch(authStateProvider);
    final signedInName = auth is AuthStateSignedIn
        ? auth.profile.displayName.trim()
        : '';
    final displayName = signedInName.isNotEmpty
        ? signedInName
        : localDisplayName;
    final greeting = _greeting(
      dayPart: currentDayPart(DateTime.now()),
      displayName: displayName,
    );
    final greetingStyle =
        (displayName.isEmpty ? typography.headlineLarge : typography.titleLarge)
            .copyWith(color: colors.textPrimary);

    Future<void> startRecommendation(Recommendation rec) async {
      try {
        if (rec.technique.safety.requiresAck) {
          final acks = await ref.read(safetyAcksProvider.future);
          if (!context.mounted) {
            return;
          }
          if (!acks.contains(rec.techniqueId)) {
            final confirmed = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              builder: (context) =>
                  SafetyWarningSheet(technique: rec.technique),
            );
            if (confirmed != true) {
              return;
            }
          }
        }

        ref
            .read(activeSessionConfigProvider.notifier)
            .setConfig(
              ActiveSessionConfig(
                technique: rec.technique,
                preset: rec.preset,
                presetId: rec.presetId,
                durationLimitSeconds: durationMinutes * 60,
              ),
            );

        if (!context.mounted) {
          return;
        }
        context.go('/session');
      } catch (_) {
        if (!context.mounted) {
          return;
        }
        showMessage('Could not start session. Please try again.');
      }
    }

    final recommendationCard = recommendation.when(
      data: (rec) {
        return TodaysPracticeCard(
          techniqueName: rec.technique.name,
          presetLabel: rec.preset.label,
          durationMinutes: durationMinutes,
          rationale: rec.rationale,
          onStart: () => startRecommendation(rec),
        );
      },
      loading: () {
        return Container(
          padding: EdgeInsets.all(components.cardPadding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(components.cardRadius),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Text(
                  'Loading today’s practice...',
                  style: typography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        return Container(
          padding: EdgeInsets.all(components.cardPadding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(components.cardRadius),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Could not load today’s practice.',
                style: typography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              OutlinedButton(
                onPressed: () => ref.invalidate(dailyRecommendationProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );

    final streakDays = stats.asData?.value.currentStreakDays;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      greeting,
                      style: greetingStyle,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
                if (kDebugMode) ...[
                  SizedBox(height: spacing.md),
                  OutlinedButton(
                    onPressed: () => context.push('/home/design-system'),
                    child: const Text('Open Design System'),
                  ),
                ],
                SizedBox(height: spacing.xl),
                recommendationCard,
                SizedBox(height: spacing.xl),
                Text(
                  'Goals',
                  style: typography.titleMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: spacing.sm),
                GoalShortcutRow(
                  selectedGoal: selectedGoal,
                  onSelect: (goal) =>
                      ref.read(activeGoalProvider.notifier).select(goal),
                ),
                SizedBox(height: spacing.xl),
                Text(
                  'Favorites',
                  style: typography.titleMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: spacing.sm),
                favorites.when(
                  data: (items) {
                    return FavoritesRow(
                      favorites: items,
                      onOpen: (technique) =>
                          context.go('/techniques/${technique.id}'),
                    );
                  },
                  loading: () => const FavoritesRow(
                    favorites: <Technique>[],
                    onOpen: _ignoreOpen,
                  ),
                  error: (error, stackTrace) => const FavoritesRow(
                    favorites: <Technique>[],
                    onOpen: _ignoreOpen,
                  ),
                ),
                SizedBox(height: spacing.xl),
                StreakDisplay(streakDays: streakDays, loading: stats.isLoading),
                SizedBox(height: spacing.lg),
                weeklyMinutes.when(
                  data: (minutes) => WeeklyBarChart(minutes: minutes),
                  loading: () =>
                      const WeeklyBarChart(minutes: <int>[], loading: true),
                  error: (error, stackTrace) =>
                      const WeeklyBarChart(minutes: <int>[]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

PrimaryGoal _selectGoal(Set<PrimaryGoal> goals) {
  for (final goal in PrimaryGoal.values) {
    if (goals.contains(goal)) {
      return goal;
    }
  }
  return PrimaryGoal.calm;
}

String _greeting({required DayPart dayPart, required String displayName}) {
  final safeName = displayName.trim();
  final base = switch (dayPart) {
    DayPart.morning => 'Good morning',
    DayPart.afternoon => 'Good afternoon',
    DayPart.evening => 'Good evening',
    DayPart.night => 'Good night',
  };

  if (safeName.isEmpty) {
    return base;
  }
  return '$base, $safeName';
}

void _ignoreOpen(Technique _) {}
