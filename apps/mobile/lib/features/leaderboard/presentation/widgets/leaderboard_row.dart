import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/leaderboard_entry.dart';
import '../../domain/leaderboard_ranking.dart';
import 'seeded_avatar.dart';

class LeaderboardRowWidget extends StatelessWidget {
  const LeaderboardRowWidget({
    super.key,
    required this.entry,
    required this.ranking,
    required this.isSelf,
  });

  final LeaderboardEntry entry;
  final LeaderboardRanking ranking;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final metric = '${entry.metricValue} ${ranking.metricLabel()}';
    final rankText = entry.rank?.toString() ?? '—';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      decoration: BoxDecoration(
        color: isSelf ? colors.surfaceHigh : colors.surface,
        borderRadius: BorderRadius.circular(components.cardRadius),
        border: Border.all(color: isSelf ? colors.focus : colors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              rankText,
              style: typography.titleMedium.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: spacing.md),
          SeededAvatar(seed: entry.avatarSeed, size: 36),
          SizedBox(width: spacing.md),
          Expanded(
            child: Text(
              entry.displayNameOrInitials,
              style: typography.bodyLarge.copyWith(color: colors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: spacing.md),
          Text(
            metric,
            style: typography.titleMedium.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
