import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';

class OnboardingOptionButton extends StatelessWidget {
  const OnboardingOptionButton({
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
    final components = Theme.of(context).extension<AppComponentTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(components.cardRadius),
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
            horizontal: spacing.lg,
            vertical: spacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: typography.bodyLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_rounded, color: colors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
