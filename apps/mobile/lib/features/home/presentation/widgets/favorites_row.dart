import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../techniques/domain/technique.dart';

class FavoritesRow extends StatelessWidget {
  const FavoritesRow({
    super.key,
    required this.favorites,
    required this.onOpen,
  });

  final List<Technique> favorites;
  final ValueChanged<Technique> onOpen;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    if (favorites.isEmpty) {
      return Container(
        padding: EdgeInsets.all(components.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(components.cardRadius),
          border: Border.all(color: colors.border),
        ),
        child: Text(
          'Favorite techniques will show up here.',
          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: favorites.length,
        separatorBuilder: (context, index) => SizedBox(width: spacing.md),
        itemBuilder: (context, index) {
          final technique = favorites[index];
          return _FavoriteCard(
            technique: technique,
            onTap: () => onOpen(technique),
          );
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.technique, required this.onTap});

  final Technique technique;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(components.cardRadius),
      side: BorderSide(color: colors.border),
    );

    return Material(
      color: colors.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 160,
          child: Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _animationIcon(technique.animationMode),
                  color: colors.textTertiary,
                  size: 18,
                ),
                const Spacer(),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _animationIcon(AnimationMode mode) {
    return switch (mode) {
      AnimationMode.circle => Icons.circle_outlined,
      AnimationMode.metronome => Icons.speed_rounded,
      AnimationMode.alternateNostril => Icons.swap_horiz_rounded,
    };
  }
}
