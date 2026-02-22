import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';

class TodaysPracticeCard extends StatelessWidget {
  const TodaysPracticeCard({
    super.key,
    required this.techniqueName,
    required this.presetLabel,
    required this.durationMinutes,
    required this.rationale,
    required this.onStart,
  });

  final String techniqueName;
  final String presetLabel;
  final int durationMinutes;
  final String rationale;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

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
            'Today’s practice',
            style: typography.labelLarge.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.sm),
          Text(
            techniqueName,
            style: typography.titleLarge.copyWith(color: colors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: spacing.xs),
          Text(
            '$presetLabel • $durationMinutes min',
            style: typography.bodyMedium.copyWith(color: colors.textTertiary),
          ),
          SizedBox(height: spacing.md),
          Text(
            rationale,
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.lg),
          FilledButton(onPressed: onStart, child: const Text('Start session')),
        ],
      ),
    );
  }
}
