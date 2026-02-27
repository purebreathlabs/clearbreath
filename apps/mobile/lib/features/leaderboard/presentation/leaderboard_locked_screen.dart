import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../../shared/widgets/server_status_dot.dart';

class LeaderboardLockedScreen extends StatelessWidget {
  const LeaderboardLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    return Scaffold(
      appBar: AppBar(
        title: const BrandMark(),
        automaticallyImplyLeading: false,
        actions: const [ServerStatusDot()],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: colors.border),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.lock_rounded,
                      color: colors.textPrimary,
                      size: 34,
                    ),
                  ),
                  SizedBox(height: spacing.lg),
                  Text(
                    'Leaderboard is locked',
                    style: typography.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing.sm),
                  Text(
                    'Sign in to join the community leaderboard.',
                    style: typography.bodyLarge.copyWith(
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    'You can opt out anytime from your profile.',
                    style: typography.bodyMedium.copyWith(
                      color: colors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.push('/auth/sign-in'),
                      child: const Text('Sign in'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
