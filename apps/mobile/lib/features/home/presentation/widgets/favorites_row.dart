import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/utils/category_colors.dart';
import '../../../../shared/utils/technique_assets.dart';
import '../../../onboarding/domain/onboarding_answers.dart';
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
      return SizedBox(
        width: double.infinity,
        child: Container(
          padding: EdgeInsets.all(components.cardPadding),
          decoration: BoxDecoration(
            color: colors.surfaceHigh,
            borderRadius: BorderRadius.circular(components.cardRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 32,
                color: colors.textTertiary,
              ),
              SizedBox(height: spacing.sm),
              Text(
                'No favorites yet',
                style: typography.titleMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                'Tap the heart on any technique to add it here.',
                style: typography.bodyMedium.copyWith(
                  color: colors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
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

    final imagePath = techniqueImageAsset(technique.id);
    final firstGoal = technique.goals.firstOrNull;

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(components.cardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 140,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imagePath != null)
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Container(color: colors.surfaceHigh),
                )
              else
                Container(color: colors.surfaceHigh),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: spacing.sm,
                right: spacing.sm,
                bottom: spacing.sm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      technique.name,
                      style: typography.titleMedium.copyWith(
                        color: colors.textPrimary,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (firstGoal != null) ...[
                      SizedBox(height: spacing.xs),
                      _MiniCategoryPill(goal: firstGoal),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniCategoryPill extends StatelessWidget {
  const _MiniCategoryPill({required this.goal});

  final PrimaryGoal goal;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyleFor(goal);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          color: style.color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
