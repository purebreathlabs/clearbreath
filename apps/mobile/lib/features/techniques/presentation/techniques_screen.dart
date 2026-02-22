import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../../shared/providers/preferences_provider.dart';
import '../../../shared/utils/category_colors.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../onboarding/domain/onboarding_answers.dart';
import '../../session/domain/active_session_config.dart';
import '../data/technique_repository.dart';
import '../domain/favorites_provider.dart';
import '../domain/favorites_repository.dart';
import '../domain/safety_acknowledgement_repository.dart';
import '../domain/technique.dart';
import '../domain/technique_filter_provider.dart';
import 'widgets/safety_warning_sheet.dart';
import 'widgets/technique_card.dart';

class TechniquesScreen extends ConsumerWidget {
  const TechniquesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final filtered = ref.watch(filteredTechniquesProvider);
    final filter = ref.watch(techniqueFilterProvider);
    final favorites = ref.watch(favoriteTechniqueIdsProvider);
    final favoriteIds = favorites.maybeWhen(
      data: (ids) => ids,
      orElse: () => const <String>{},
    );

    Future<void> toggleFavorite(String techniqueId) async {
      try {
        await ref.read(favoritesRepositoryProvider).toggle(techniqueId);
        ref.invalidate(favoriteTechniqueIdsProvider);
      } catch (_) {
        if (!context.mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Could not update favorite. Please try again.',
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
    }

    Future<void> quickPlay(Technique technique) async {
      try {
        if (technique.safety.requiresAck) {
          final acks = await ref.read(safetyAcksProvider.future);
          if (!context.mounted) return;
          if (!acks.contains(technique.id)) {
            final confirmed = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              builder: (_) => SafetyWarningSheet(technique: technique),
            );
            if (confirmed != true) return;
          }
        }

        final preset =
            technique.presets['beginner'] ??
            technique.presets.values.firstOrNull;
        if (preset == null) return;

        final prefs = ref.read(preferencesProvider);
        final durationMinutes = prefs.asData?.value?.sessionLengthMinutes ?? 5;

        ref
            .read(activeSessionConfigProvider.notifier)
            .setConfig(
              ActiveSessionConfig(
                technique: technique,
                preset: preset,
                presetId: preset.id,
                durationLimitSeconds: durationMinutes * 60,
              ),
            );

        if (!context.mounted) return;
        context.go('/session');
      } catch (_) {
        if (!context.mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Could not start session. Please try again.',
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
    }

    return Scaffold(
      appBar: AppBar(
        title: const BrandMark(),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.lg),
              child: TextField(
                key: const Key('techniques_search_field'),
                onChanged: (value) {
                  ref
                      .read(techniqueFilterProvider.notifier)
                      .update(filter.copyWith(searchQuery: value));
                },
                style: typography.bodyMedium.copyWith(
                  color: colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search techniques...',
                  hintStyle: typography.bodyMedium.copyWith(
                    color: colors.textTertiary,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.textTertiary,
                  ),
                  suffixIcon: filter.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: colors.textTertiary,
                          ),
                          onPressed: () {
                            ref
                                .read(techniqueFilterProvider.notifier)
                                .update(filter.copyWith(searchQuery: ''));
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colors.surfaceHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(components.inputRadius),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: spacing.lg,
                    vertical: spacing.md,
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing.md),
            Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.xs),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: spacing.lg),
                  children: [
                    _FilterChip(
                      key: const Key('filter_chip_all'),
                      label: 'All',
                      selected: filter.selectedGoals.isEmpty,
                      color: colors.textPrimary,
                      colors: colors,
                      typography: typography,
                      onTap: () {
                        ref
                            .read(techniqueFilterProvider.notifier)
                            .update(filter.copyWith(selectedGoals: {}));
                      },
                    ),
                    SizedBox(width: spacing.sm),
                    for (final goal in PrimaryGoal.values) ...[
                      _FilterChip(
                        key: Key('filter_chip_${goal.name}'),
                        label: categoryStyleFor(goal).label,
                        selected: filter.selectedGoals.contains(goal),
                        color: categoryStyleFor(goal).color,
                        colors: colors,
                        typography: typography,
                        onTap: () {
                          final goals = Set<PrimaryGoal>.from(
                            filter.selectedGoals,
                          );
                          if (goals.contains(goal)) {
                            goals.remove(goal);
                          } else {
                            goals.add(goal);
                          }
                          ref
                              .read(techniqueFilterProvider.notifier)
                              .update(filter.copyWith(selectedGoals: goals));
                        },
                      ),
                      SizedBox(width: spacing.sm),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.sm),
            Expanded(
              child: filtered.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(spacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Could not load techniques.',
                            style: typography.bodyLarge.copyWith(
                              color: colors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: spacing.lg),
                          OutlinedButton(
                            onPressed: () =>
                                ref.invalidate(allTechniquesProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: colors.textTertiary,
                          ),
                          SizedBox(height: spacing.md),
                          Text(
                            'No techniques match',
                            style: typography.titleMedium.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          SizedBox(height: spacing.md),
                          OutlinedButton(
                            onPressed: () {
                              ref
                                  .read(techniqueFilterProvider.notifier)
                                  .reset();
                            },
                            child: const Text('Clear filters'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing.lg),
                    child: GridView.count(
                      physics: const ClampingScrollPhysics(),
                      key: const Key('techniques_grid'),
                      crossAxisCount: 2,
                      crossAxisSpacing: spacing.md,
                      mainAxisSpacing: spacing.md,
                      childAspectRatio: 0.72,
                      children: [
                        for (final technique in items)
                          TechniqueCard(
                            key: Key('technique_card_${technique.id}'),
                            technique: technique,
                            onTap: () =>
                                context.push('/techniques/${technique.id}'),
                            favorited: favoriteIds.contains(technique.id),
                            onToggleFavorite: () =>
                                toggleFavorite(technique.id),
                            onQuickPlay: () => quickPlay(technique),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.color,
    required this.colors,
    required this.typography,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final AppColorTokens colors;
  final AppTypographyTokens typography;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : colors.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.5) : colors.border,
            width: selected ? 1.2 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: typography.labelMedium.copyWith(
            color: selected ? color : colors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
