import 'package:flutter/material.dart';
import '../../core/theme/theme_extensions.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.logoSize = 22,
    this.showText = true,
    this.textStyle,
  });

  final double logoSize;
  final bool showText;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;

    final style = (textStyle ?? typography.titleMedium).copyWith(
      color: colors.textPrimary,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/branding/logo.png',
          width: logoSize,
          height: logoSize,
          semanticLabel: 'ClearBreath',
          color: colors.textPrimary,
          colorBlendMode: BlendMode.srcIn,
        ),
        if (showText) ...[
          SizedBox(width: spacing.sm),
          Text('ClearBreath', style: style),
        ],
      ],
    );
  }
}
