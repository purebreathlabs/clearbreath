import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/technique.dart';

class TechniqueCard extends StatelessWidget {
  const TechniqueCard({
    super.key,
    required this.technique,
    required this.onTap,
    this.onToggleFavorite,
    this.favorited = false,
  });

  final Technique technique;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;
  final bool favorited;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final goalLabels =
        technique.goals
            .map((goal) => _goalLabel(goal.name))
            .toList(growable: false)
          ..sort();
    final goalsText = goalLabels.take(2).join(' • ');

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(components.cardRadius),
      side: BorderSide(color: components.cardBorder),
    );

    return Material(
      color: components.cardBackground,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(components.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _animationIcon(technique.animationMode),
                    color: colors.textTertiary,
                    size: 18,
                  ),
                  if (technique.safety.requiresAck) ...[
                    SizedBox(width: spacing.sm),
                    Icon(
                      Icons.warning_amber_rounded,
                      color: colors.textTertiary,
                      size: 18,
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    key: Key('favorite_toggle_${technique.id}'),
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      favorited
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                    ),
                    color: favorited ? colors.textPrimary : colors.textTertiary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    splashRadius: 24,
                    tooltip: favorited ? 'Unfavorite' : 'Favorite',
                  ),
                ],
              ),
              SizedBox(height: spacing.sm),
              Text(
                technique.name,
                style: typography.titleMedium.copyWith(
                  color: colors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: spacing.xs),
              Text(
                technique.shortDescription,
                style: typography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (goalsText.isNotEmpty) ...[
                SizedBox(height: spacing.xs),
                Text(
                  goalsText,
                  style: typography.labelMedium.copyWith(
                    color: colors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _goalLabel(String value) {
    if (value == 'hrv') {
      return 'HRV';
    }
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  IconData _animationIcon(AnimationMode mode) {
    return switch (mode) {
      AnimationMode.circle => Icons.circle_outlined,
      AnimationMode.metronome => Icons.speed_rounded,
      AnimationMode.alternateNostril => Icons.swap_horiz_rounded,
    };
  }
}
