import 'package:flutter/material.dart';

import '../../core/theme/theme_extensions.dart';

class SelectionPill extends StatelessWidget {
  const SelectionPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.centerLabel = true,
    this.padding,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool centerLabel;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(components.buttonRadius),
      side: BorderSide(color: selected ? colors.focus : colors.border),
    );

    return Material(
      color: selected ? colors.surfaceHigh : colors.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm,
              ),
          child: Align(
            alignment: centerLabel ? Alignment.center : Alignment.centerLeft,
            child: Text(
              label,
              style: typography.labelLarge.copyWith(color: colors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
