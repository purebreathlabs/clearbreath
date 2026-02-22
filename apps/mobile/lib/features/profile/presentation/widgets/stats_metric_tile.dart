import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';

class StatsMetricTile extends StatelessWidget {
  const StatsMetricTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

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
        child: Padding(
          padding: EdgeInsets.all(components.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colors.textTertiary, size: 18),
              SizedBox(height: spacing.md),
              Text(
                value,
                style: typography.headlineLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                label,
                style: typography.labelMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
