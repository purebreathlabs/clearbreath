import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';

@immutable
class TechniqueBreakdownEntry {
  const TechniqueBreakdownEntry({required this.label, required this.minutes});

  final String label;
  final int minutes;
}

class TechniqueBreakdownList extends StatelessWidget {
  const TechniqueBreakdownList({super.key, required this.entries});

  final List<TechniqueBreakdownEntry> entries;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    if (entries.isEmpty) {
      return Text(
        'No practice yet.',
        style: typography.bodyMedium.copyWith(color: colors.textSecondary),
      );
    }

    final maxMinutes = entries.map((e) => max(0, e.minutes)).reduce(max);
    final safeMax = maxMinutes <= 0 ? 1 : maxMinutes;

    return Column(
      children: [
        for (final entry in entries) ...[
          _BreakdownRow(
            entry: entry,
            maxMinutes: safeMax,
          ),
          SizedBox(height: spacing.md),
        ],
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.entry, required this.maxMinutes});

  final TechniqueBreakdownEntry entry;
  final int maxMinutes;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    final minutes = entry.minutes < 0 ? 0 : entry.minutes;
    final fraction = (minutes / maxMinutes).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                entry.label,
                style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: spacing.md),
            Text(
              '${minutes}m',
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final fill = width * fraction;
            return Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.surfaceHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  height: 8,
                  width: fill,
                  decoration: BoxDecoration(
                    color: colors.textPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
