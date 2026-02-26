import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';

class OnboardingOptionButton extends StatelessWidget {
  const OnboardingOptionButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.recommended = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? subtitle;
  final bool recommended;

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

    return Semantics(
      label:
          '$label${subtitle != null ? ', $subtitle' : ''}${selected ? ', selected' : ''}',
      child: Material(
        color: selected ? colors.surfaceHigh : colors.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.lg,
              vertical: subtitle != null ? spacing.lg : spacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: typography.bodyLarge.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          if (recommended) ...[
                            SizedBox(width: spacing.sm),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing.sm,
                                vertical: spacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: colors.focus.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  components.buttonRadius,
                                ),
                              ),
                              child: Text(
                                'Recommended',
                                style: typography.labelMedium.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: spacing.xs),
                        Text(
                          subtitle!,
                          style: typography.bodyMedium.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_rounded, color: colors.textPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
