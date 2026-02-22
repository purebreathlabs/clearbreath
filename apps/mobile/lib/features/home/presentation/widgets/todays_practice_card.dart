import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/utils/technique_assets.dart';

class TodaysPracticeCard extends StatelessWidget {
  const TodaysPracticeCard({
    super.key,
    required this.techniqueName,
    required this.presetLabel,
    required this.durationMinutes,
    required this.rationale,
    required this.onStart,
    this.techniqueId,
  });

  final String techniqueName;
  final String presetLabel;
  final int durationMinutes;
  final String rationale;
  final VoidCallback onStart;
  final String? techniqueId;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final imagePath = techniqueId != null
        ? techniqueImageAsset(techniqueId!)
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(components.cardRadius),
      child: Stack(
        children: [
          if (imagePath != null)
            Positioned(
              right: -20,
              top: -10,
              bottom: -10,
              width: 180,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    colors.surface,
                    colors.surface.withValues(alpha: 0.95),
                    colors.surface.withValues(alpha: 0.6),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: components.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Today\u2019s practice',
                  style: typography.labelLarge.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  techniqueName,
                  style: typography.titleLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.xs),
                Text(
                  '$presetLabel \u2022 $durationMinutes min',
                  style: typography.bodyMedium.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                SizedBox(height: spacing.md),
                Text(
                  rationale,
                  style: typography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: spacing.lg),
                FilledButton(
                  onPressed: onStart,
                  child: const Text('Start session'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
