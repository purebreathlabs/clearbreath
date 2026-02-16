import 'package:flutter/material.dart';

import '../../../core/theme/theme_extensions.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Center(
            child: Text(
              'Stats',
              style: typography.titleLarge.copyWith(color: colors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
