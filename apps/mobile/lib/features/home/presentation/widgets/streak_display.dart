import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';

class StreakDisplay extends StatelessWidget {
  const StreakDisplay({super.key, required this.streakDays, this.loading = false});

  final int? streakDays;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final value = loading ? '—' : (streakDays ?? 0).toString();

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
          Text(
            'Streak',
            style: typography.labelMedium.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: typography.displayMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(width: spacing.sm),
              Padding(
                padding: EdgeInsets.only(bottom: spacing.xs),
                child: Text(
                  'days',
                  style: typography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
