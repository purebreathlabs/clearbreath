import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../xp/domain/xp_history_provider.dart';

class XPHistorySection extends ConsumerWidget {
  const XPHistorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final historyAsync = ref.watch(xpHistoryProvider(7));

    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (days) {
        if (days.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.all(components.cardPadding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(components.cardRadius),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '7-Day XP',
                style: typography.titleMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: spacing.md),
              for (var i = 0; i < days.length; i++) ...[
                _DayRow(entry: days[i]),
                if (i < days.length - 1)
                  Divider(height: 1, color: colors.divider),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.entry});

  final XPDayEntry entry;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    final dayLabel = _formatDay(entry.localDay);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dayLabel,
              style: typography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          Text(
            '+${entry.totalXP} XP',
            style: typography.titleMedium.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }

  String _formatDay(String localDay) {
    try {
      final date = DateTime.parse(localDay);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final diff = today
          .difference(DateTime(date.year, date.month, date.day))
          .inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    } catch (_) {
      return localDay;
    }
  }
}
