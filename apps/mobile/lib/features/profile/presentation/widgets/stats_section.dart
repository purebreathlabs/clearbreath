import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/widgets/weekly_bar_chart.dart';
import '../../../stats/domain/stats_snapshot.dart';
import '../../../stats/domain/weekly_minutes_provider.dart';
import '../../../sync/domain/merged_stats_provider.dart';
import '../../../techniques/data/technique_repository.dart';
import '../../../techniques/domain/technique.dart';
import 'stats_metric_tile.dart';
import 'technique_breakdown_list.dart';

class StatsSection extends ConsumerStatefulWidget {
  const StatsSection({super.key});

  @override
  ConsumerState<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends ConsumerState<StatsSection> {
  int _weekOffset = 0;

  static const int _minWeekOffset = -52;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final stats = ref.watch(mergedStatsProvider);
    final weekly = ref.watch(weeklyMinutesProvider(_weekOffset));
    final techniques = ref.watch(allTechniquesProvider);

    Widget errorState(String message) {
      return Container(
        padding: EdgeInsets.all(components.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(components.cardRadius),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              style: typography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: spacing.md),
            OutlinedButton(
              onPressed: () {
                ref.invalidate(mergedStatsProvider);
                ref.invalidate(weeklyMinutesProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return stats.when(
      skipLoadingOnReload: true,
      loading: () {
        return Container(
          padding: EdgeInsets.all(components.cardPadding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(components.cardRadius),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Text(
                  'Loading stats...',
                  style: typography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => errorState('Could not load stats.'),
      data: (snapshot) {
        final tiles = _tiles(snapshot);
        final breakdown = _breakdownEntries(
          snapshot: snapshot,
          techniques: techniques.asData?.value,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth = (constraints.maxWidth - spacing.md) / 2.0;
                return Wrap(
                  spacing: spacing.md,
                  runSpacing: spacing.md,
                  children: [
                    for (final tile in tiles)
                      SizedBox(width: tileWidth, child: tile),
                  ],
                );
              },
            ),
            SizedBox(height: spacing.lg),
            weekly.when(
              skipLoadingOnReload: true,
              data: (minutes) => WeeklyBarChart(
                minutes: minutes,
                title: weekTitle(_weekOffset),
                onPrevious: _weekOffset > _minWeekOffset
                    ? () => setState(() => _weekOffset--)
                    : null,
                onNext: () {
                  if (_weekOffset < 0) {
                    setState(() => _weekOffset++);
                  }
                },
                canGoNext: _weekOffset < 0,
              ),
              loading: () =>
                  const WeeklyBarChart(minutes: <int>[], loading: true),
              error: (error, stackTrace) =>
                  const WeeklyBarChart(minutes: <int>[]),
            ),
            SizedBox(height: spacing.lg),
            Text(
              'By technique',
              style: typography.titleMedium.copyWith(color: colors.textPrimary),
            ),
            SizedBox(height: spacing.sm),
            TechniqueBreakdownList(entries: breakdown),
          ],
        );
      },
    );
  }

  List<Widget> _tiles(StatsSnapshot snapshot) {
    return [
      StatsMetricTile(
        icon: Icons.local_fire_department_outlined,
        label: 'Streak',
        value: '${max(0, snapshot.currentStreakDays)}',
      ),
      StatsMetricTile(
        icon: Icons.schedule_rounded,
        label: 'Minutes',
        value: '${max(0, snapshot.minutesAllTime)}',
      ),
      StatsMetricTile(
        icon: Icons.check_circle_outline_rounded,
        label: 'Sessions',
        value: '${max(0, snapshot.sessionsAllTime)}',
      ),
      StatsMetricTile(
        icon: Icons.calendar_today_rounded,
        label: 'This week',
        value: '${max(0, snapshot.minutesThisWeek)}',
      ),
    ];
  }

  List<TechniqueBreakdownEntry> _breakdownEntries({
    required StatsSnapshot snapshot,
    required List<Technique>? techniques,
  }) {
    final nameById = <String, String>{};
    if (techniques != null) {
      for (final technique in techniques) {
        nameById[technique.id] = technique.name;
      }
    }

    final items = <TechniqueBreakdownEntry>[];
    for (final entry in snapshot.minutesByTechnique.entries) {
      final minutes = entry.value < 0 ? 0 : entry.value;
      if (minutes <= 0) {
        continue;
      }
      final label = nameById[entry.key] ?? _titleCaseId(entry.key);
      items.add(TechniqueBreakdownEntry(label: label, minutes: minutes));
    }

    items.sort((a, b) {
      final byMinutes = b.minutes.compareTo(a.minutes);
      if (byMinutes != 0) {
        return byMinutes;
      }
      return a.label.compareTo(b.label);
    });
    return items;
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
}
