import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';

class OnboardingQuestion extends StatelessWidget {
  const OnboardingQuestion({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: typography.titleLarge),
        if (subtitle != null) ...[
          SizedBox(height: spacing.sm),
          Text(
            subtitle!,
            style: typography.bodyLarge.copyWith(color: colors.textSecondary),
          ),
        ],
        SizedBox(height: spacing.xl),
        child,
      ],
    );
  }
}
