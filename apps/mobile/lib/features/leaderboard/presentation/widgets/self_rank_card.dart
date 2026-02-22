import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/leaderboard_entry.dart';
import '../../domain/leaderboard_ranking.dart';
import 'seeded_avatar.dart';

class SelfRankCard extends StatelessWidget {
  const SelfRankCard({
    super.key,
    required this.entry,
    required this.ranking,
    required this.loading,
  });

  final LeaderboardEntry? entry;
  final LeaderboardRanking ranking;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final rankValue = entry?.rank;
    final rankLabel = loading
        ? 'Loading...'
        : (rankValue == null ? 'Not ranked yet' : '#$rankValue');

    final metricValue = entry?.metricValue ?? 0;
    final metricLabel = '$metricValue ${ranking.metricLabel()}';

    return Container(
      key: const Key('self_rank_card'),
      padding: EdgeInsets.all(components.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(components.cardRadius),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          SeededAvatar(
            seed: entry?.avatarSeed ?? '',
            size: 44,
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You',
                  style: typography.titleMedium.copyWith(color: colors.textPrimary),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  rankLabel,
                  style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            metricLabel,
            style: typography.titleMedium.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
