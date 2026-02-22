import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/auth_state.dart';
import '../../auth/domain/auth_state_provider.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../domain/leaderboard_controller.dart';
import 'widgets/leaderboard_row.dart';
import 'widgets/ranking_selector.dart';
import 'widgets/self_rank_card.dart';
import 'leaderboard_locked_screen.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    if (authState is AuthStateSignedIn) {
      return const _LeaderboardSignedInScreen();
    }
    return const LeaderboardLockedScreen();
  }
}

class _LeaderboardSignedInScreen extends ConsumerWidget {
  const _LeaderboardSignedInScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final auth = ref.watch(authStateProvider);
    final userId = auth is AuthStateSignedIn ? auth.profile.id : '';

    final state = ref.watch(leaderboardControllerProvider);
    final controller = ref.read(leaderboardControllerProvider.notifier);

    final updatedLabel = _updatedLabel(state.fetchedAtUtc);

    Widget banner(String message) {
      return Container(
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceHigh,
          borderRadius: BorderRadius.circular(components.cardRadius),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: colors.textPrimary),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(
                message,
                style: typography.bodyMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget content() {
      if (state.loading && state.entries.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (state.errorMessage != null && state.entries.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.errorMessage!,
                  style: typography.bodyLarge.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.lg),
                OutlinedButton(
                  onPressed: controller.refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: spacing.lg),
          itemBuilder: (context, index) {
            final entry = state.entries[index];
            return LeaderboardRowWidget(
              entry: entry,
              ranking: state.ranking,
              isSelf: entry.userId == userId,
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: spacing.sm),
          itemCount: state.entries.length,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const BrandMark(),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RankingSelector(
                selected: state.ranking,
                onSelect: controller.selectRanking,
              ),
              SizedBox(height: spacing.md),
              if (state.bannerMessage != null) ...[
                banner(state.bannerMessage!),
                SizedBox(height: spacing.md),
              ],
              Text(
                'Last updated $updatedLabel',
                style: typography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Expanded(child: content()),
              SizedBox(height: spacing.md),
              SelfRankCard(
                entry: state.self,
                ranking: state.ranking,
                loading: state.loading && state.self == null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _updatedLabel(DateTime? fetchedAtUtc) {
  if (fetchedAtUtc == null) {
    return '—';
  }
  final diff = DateTime.now().toUtc().difference(fetchedAtUtc.toUtc());
  if (diff.inMinutes < 1) {
    return 'just now';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  }
  return '${diff.inDays}d ago';
}
