import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../xp/domain/xp_provider.dart';

class LevelCard extends ConsumerWidget {
  const LevelCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final xpAsync = ref.watch(mergedXPProvider);

    return xpAsync.when(
      skipLoadingOnReload: true,
      loading: () => Container(
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
                'Loading level...',
                style: typography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (xp) {
        final progressXP = xp.xpProgressInLevel;
        final neededXP = xp.xpForNextLevel;
        final progressLabel = neededXP > 0
            ? '$progressXP / $neededXP XP'
            : '${xp.totalXP} XP (max level)';

        return Container(
          padding: EdgeInsets.all(components.cardPadding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(components.cardRadius),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Level ${xp.currentLevel}',
                    style: typography.headlineLarge.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${xp.totalXP} XP',
                    style: typography.titleMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: xp.progressFraction,
                  minHeight: 8,
                  backgroundColor: colors.surfaceHigh,
                  valueColor: AlwaysStoppedAnimation(colors.textPrimary),
                ),
              ),
              SizedBox(height: spacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    progressLabel,
                    style: typography.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  if (xp.currentStreakDays > 0)
                    Text(
                      '${xp.currentMultiplier.toStringAsFixed(1)}x streak',
                      style: typography.labelMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
