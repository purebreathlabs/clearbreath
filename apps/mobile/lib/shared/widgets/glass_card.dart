import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/theme_extensions.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 18,
    this.padding,
    this.sigma = 10,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double sigma;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    final bg = backgroundColor ?? colors.surfaceHigh.withValues(alpha: 0.6);
    final border = borderColor ?? colors.border.withValues(alpha: 0.4);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: border),
          ),
          child: child,
        ),
      ),
    );
  }
}
