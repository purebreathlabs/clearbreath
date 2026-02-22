import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../techniques/data/technique_repository.dart';
import '../../techniques/domain/technique.dart';
import '../../profile/presentation/widgets/stats_metric_tile.dart';
import '../../profile/presentation/widgets/stats_section.dart';
import '../../sync/domain/merged_stats_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final stats = ref.watch(mergedStatsProvider);
    final techniques = ref.watch(allTechniquesProvider);

    final favoriteLabel = stats.when(
      data: (snapshot) {
        final id = snapshot.favoriteTechniqueId;
        if (id == null) {
          return '—';
        }
        final list = techniques.asData?.value;
        if (list == null) {
          return _titleCaseId(id);
        }
        return _findTechniqueName(list, id) ?? _titleCaseId(id);
      },
      loading: () => '—',
      error: (error, stackTrace) => '—',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const StatsSection(),
                SizedBox(height: spacing.xl),
                Text(
                  'Highlights',
                  style: typography.titleMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: spacing.sm),
                stats.when(
                  loading: () => Container(
                    padding: EdgeInsets.all(components.cardPadding),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        components.cardRadius,
                      ),
                      border: Border.all(color: colors.border),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => Container(
                    padding: EdgeInsets.all(components.cardPadding),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        components.cardRadius,
                      ),
                      border: Border.all(color: colors.border),
                    ),
                    child: Text(
                      'Could not load stats.',
                      style: typography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  data: (snapshot) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final tileWidth =
                            (constraints.maxWidth - spacing.md) / 2.0;
                        return Wrap(
                          spacing: spacing.md,
                          runSpacing: spacing.md,
                          children: [
                            SizedBox(
                              width: tileWidth,
                              child: StatsMetricTile(
                                icon: Icons.emoji_events_outlined,
                                label: 'Longest streak',
                                value: '${snapshot.longestStreakDays}',
                              ),
                            ),
                            SizedBox(
                              width: tileWidth,
                              child: StatsMetricTile(
                                icon: Icons.timer_outlined,
                                label: 'Longest session',
                                value: '${snapshot.longestSessionMinutes}m',
                              ),
                            ),
                            SizedBox(
                              width: tileWidth,
                              child: StatsMetricTile(
                                icon: Icons.favorite_border_rounded,
                                label: 'Top technique',
                                value: favoriteLabel,
                              ),
                            ),
                            SizedBox(
                              width: tileWidth,
                              child: StatsMetricTile(
                                icon: Icons.air_rounded,
                                label: 'Breaths',
                                value: '${snapshot.totalBreathsEstimated}',
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _findTechniqueName(List<Technique> techniques, String id) {
  for (final technique in techniques) {
    if (technique.id == id) {
      return technique.name;
    }
  }
  return null;
}

String _titleCaseId(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'[_\\s-]+'))
      .where((p) => p.isNotEmpty);
  final words = parts
      .map((part) {
        if (part.isEmpty) {
          return part;
        }
        final lower = part.toLowerCase();
        return lower[0].toUpperCase() + lower.substring(1);
      })
      .toList(growable: false);
  return words.isEmpty ? value : words.join(' ');
}
