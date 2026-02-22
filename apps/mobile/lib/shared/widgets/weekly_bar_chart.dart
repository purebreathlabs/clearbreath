import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/theme_extensions.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.minutes,
    this.loading = false,
  });

  final List<int> minutes;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final values = _normalize(minutes);

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
            'This week',
            style: typography.labelMedium.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.md),
          SizedBox(
            height: 90,
            child: CustomPaint(
              painter: _WeeklyBarPainter(
                minutes: values,
                barColor: colors.textPrimary,
                backgroundColor: colors.surfaceHigh,
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
      final rect =
          Rect.fromLTWH(left, size.height - barHeight, barWidth, barHeight);
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

