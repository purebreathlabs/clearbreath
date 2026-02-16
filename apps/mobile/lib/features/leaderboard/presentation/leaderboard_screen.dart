import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/auth_state.dart';
import '../../auth/domain/auth_state_provider.dart';
import '../../../core/theme/theme_extensions.dart';
import 'leaderboard_locked_screen.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    if (authState is AuthStateSignedIn) {
      return const LeaderboardPlaceholderScreen();
    }
    return const LeaderboardLockedScreen();
  }
}

class LeaderboardPlaceholderScreen extends StatelessWidget {
  const LeaderboardPlaceholderScreen({super.key});

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
              'Leaderboard',
              key: const Key('leaderboard_placeholder_title'),
              style: typography.titleLarge.copyWith(color: colors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
