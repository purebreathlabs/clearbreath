import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';

class CompactProgressCard extends StatelessWidget {
  const CompactProgressCard({
    super.key,
    required this.streakDays,
    required this.weeklyMinutes,
    this.loading = false,
  });

  final int? streakDays;
  final List<int> weeklyMinutes;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final streakValue = loading ? '\u2014' : (streakDays ?? 0).toString();
    final values = _normalize(weeklyMinutes);
    final totalMinutes = values.fold<int>(0, (a, b) => a + b);

    return Container(
      padding: EdgeInsets.all(components.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        borderRadius: BorderRadius.circular(components.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Streak',
                    style: typography.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        streakValue,
                        style: typography.headlineLarge.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(width: spacing.xs),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'days',
                          style: typography.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'This week',
                    style: typography.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        loading ? '\u2014' : totalMinutes.toString(),
                        style: typography.headlineLarge.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(width: spacing.xs),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'min',
                          style: typography.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          SizedBox(
            height: 60,
            child: CustomPaint(
              size: Size.infinite,
              painter: _WeeklyBarPainter(
                minutes: values,
                barColor: colors.textPrimary,
                backgroundColor: colors.surface,
              ),
            ),
          ),
          SizedBox(height: spacing.sm),
          Row(
            children: [
              for (final label in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: typography.labelMedium.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<int> _normalize(List<int> value) {
    if (loading) {
      return List<int>.filled(7, 0, growable: false);
    }
    if (value.length == 7) {
      return value.map((v) => v < 0 ? 0 : v).toList(growable: false);
    }
    final normalized = List<int>.filled(7, 0);
    for (var i = 0; i < min(7, value.length); i++) {
      normalized[i] = value[i] < 0 ? 0 : value[i];
    }
    return List.unmodifiable(normalized);
  }
}

class _WeeklyBarPainter extends CustomPainter {
  _WeeklyBarPainter({
    required this.minutes,
    required this.barColor,
    required this.backgroundColor,
  });

  final List<int> minutes;
  final Color barColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gap = size.width * 0.02;
    final barWidth = (size.width - gap * 6) / 7;
    final maxMinutes = minutes.isEmpty ? 0 : minutes.reduce(max);
    final safeMax = maxMinutes <= 0 ? 1 : maxMinutes;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 7; i++) {
      final value = i < minutes.length ? minutes[i] : 0;
      final fraction = (value.clamp(0, safeMax) / safeMax).toDouble();
      final barHeight = size.height * fraction;
      final left = i * (barWidth + gap);
      final rect = Rect.fromLTWH(
        left,
        size.height - barHeight,
        barWidth,
        barHeight,
      );
      final radius = Radius.circular(barWidth / 2);

      final bgRect = Rect.fromLTWH(left, 0, barWidth, size.height);
      canvas.drawRRect(RRect.fromRectAndRadius(bgRect, radius), bgPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyBarPainter oldDelegate) {
    return oldDelegate.minutes != minutes ||
        oldDelegate.barColor != barColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
