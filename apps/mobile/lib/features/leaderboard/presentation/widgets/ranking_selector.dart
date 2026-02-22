import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/widgets/selection_pill.dart';
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
          child: SelectionPill(
            key: const Key('ranking_streak'),
            label: LeaderboardRanking.streak.label(),
            selected: selected == LeaderboardRanking.streak,
            onTap: () => onSelect(LeaderboardRanking.streak),
          ),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: SelectionPill(
            key: const Key('ranking_weekly'),
            label: LeaderboardRanking.weekly.label(),
            selected: selected == LeaderboardRanking.weekly,
            onTap: () => onSelect(LeaderboardRanking.weekly),
          ),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: SelectionPill(
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
