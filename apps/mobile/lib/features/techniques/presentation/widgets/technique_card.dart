import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/utils/category_colors.dart';
import '../../../../shared/utils/technique_assets.dart';
import '../../../onboarding/domain/onboarding_answers.dart';
import '../../domain/technique.dart';

class TechniqueCard extends StatelessWidget {
  const TechniqueCard({
    super.key,
    required this.technique,
    required this.onTap,
    this.onToggleFavorite,
    this.onQuickPlay,
    this.favorited = false,
  });

  final Technique technique;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onQuickPlay;
  final bool favorited;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final imagePath = techniqueImageAsset(technique.id);
    final goals = technique.goals.take(2).toList();

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(components.cardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: colors.surfaceHigh,
                ),
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
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.sizeOf(context).height * 0.12,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (final goal in goals) ...[
                        _CategoryPill(goal: goal),
                        SizedBox(width: spacing.xs),
                      ],
                      const Spacer(),
                      GestureDetector(
                        key: Key('favorite_toggle_${technique.id}'),
                        onTap: onToggleFavorite,
                        child: Icon(
                          favorited
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: favorited
                              ? colors.textPrimary
                              : colors.textTertiary,
                          size: 22,
                        ),
                      ),
                    ],
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
                  SizedBox(height: spacing.sm),
                  Row(
                    children: [
                      _DifficultyDots(
                        mode: technique.animationMode,
                      ),
                      SizedBox(width: spacing.sm),
                      Text(
                        _durationText(technique),
                        style: typography.labelMedium.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      if (onQuickPlay != null)
                        GestureDetector(
                          onTap: onQuickPlay,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.textPrimary.withValues(alpha: 0.15),
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: colors.textPrimary,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _durationText(Technique technique) {
    final preset = technique.presets['beginner'] ??
        technique.presets.values.firstOrNull;
    if (preset == null) return '';
    final durations = preset.recommendedDurationsMinutes;
    if (durations.isEmpty) return '';
    final defaultDuration =
        durations.length > 1 ? durations[1] : durations.first;
    return '$defaultDuration min';
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.goal});

  final PrimaryGoal goal;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyleFor(goal);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          style.color.withValues(alpha: 0.35),
          Colors.black,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: style.color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          color: style.color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DifficultyDots extends StatelessWidget {
  const _DifficultyDots({required this.mode});

  final AnimationMode mode;

  @override
  Widget build(BuildContext context) {
    final filled = switch (mode) {
      AnimationMode.circle => 1,
      AnimationMode.alternateNostril => 2,
      AnimationMode.metronome => 3,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < filled
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.15),
          ),
        );
      }),
    );
  }
}
