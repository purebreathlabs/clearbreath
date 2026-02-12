import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ClearBreath', style: typography.displayMedium),
              SizedBox(height: spacing.sm),
              Text(
                'Week 1 foundation',
                style: typography.bodyLarge.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: spacing.xl),
              FilledButton(
                onPressed: () => context.push('/design-system'),
                child: const Text('Open Design System'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
