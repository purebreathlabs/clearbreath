import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/leaderboard_ranking.dart';

class RankingSelector extends StatelessWidget {
  const RankingSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final LeaderboardRanking selected;
  final ValueChanged<LeaderboardRanking> onSelect;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;

    return Row(
      children: [
        Expanded(
          child: _Pill(
            key: const Key('ranking_streak'),
            label: LeaderboardRanking.streak.label(),
            selected: selected == LeaderboardRanking.streak,
            onTap: () => onSelect(LeaderboardRanking.streak),
          ),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: _Pill(
            key: const Key('ranking_weekly'),
            label: LeaderboardRanking.weekly.label(),
            selected: selected == LeaderboardRanking.weekly,
            onTap: () => onSelect(LeaderboardRanking.weekly),
          ),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: _Pill(
            key: const Key('ranking_all_time'),
            label: LeaderboardRanking.allTime.label(),
            selected: selected == LeaderboardRanking.allTime,
            onTap: () => onSelect(LeaderboardRanking.allTime),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(components.buttonRadius),
      side: BorderSide(color: selected ? colors.focus : colors.border),
    );

    return Material(
      color: selected ? colors.surfaceHigh : colors.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          child: Center(
            child: Text(
              label,
              style: typography.labelLarge.copyWith(color: colors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
