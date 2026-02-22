import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
import '../data/technique_repository.dart';
import '../domain/favorites_provider.dart';
import '../domain/favorites_repository.dart';
import 'widgets/technique_card.dart';

class TechniquesScreen extends ConsumerWidget {
  const TechniquesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final techniques = ref.watch(allTechniquesProvider);
    final favorites = ref.watch(favoriteTechniqueIdsProvider);
    final favoriteIds = favorites.maybeWhen(
      data: (ids) => ids,
      orElse: () => const <String>{},
    );

    Future<void> toggleFavorite(String techniqueId) async {
      try {
        await ref.read(favoritesRepositoryProvider).toggle(techniqueId);
        ref.invalidate(favoriteTechniqueIdsProvider);
      } catch (_) {
        if (!context.mounted) {
          return;
        }
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Could not update favorite. Please try again.',
              style: typography.bodyMedium.copyWith(color: colors.inverseText),
            ),
            backgroundColor: colors.inverseSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(components.buttonRadius),
            ),
          ),
        );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: techniques.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(spacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Could not load techniques.',
                      style: typography.bodyLarge.copyWith(
                        color: colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing.lg),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(allTechniquesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          },
          data: (items) {
            return Padding(
              padding: EdgeInsets.all(spacing.lg),
              child: GridView.count(
                key: const Key('techniques_grid'),
                crossAxisCount: 2,
                crossAxisSpacing: spacing.md,
                mainAxisSpacing: spacing.md,
                childAspectRatio: 0.85,
                children: [
                  for (final technique in items)
                    TechniqueCard(
                      key: Key('technique_card_${technique.id}'),
                      technique: technique,
                      onTap: () => context.push('/techniques/${technique.id}'),
                      favorited: favoriteIds.contains(technique.id),
                      onToggleFavorite: () => toggleFavorite(technique.id),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
