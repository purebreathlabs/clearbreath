import 'dart:math';

import 'package:flutter/material.dart';

class BreathingRingPainter extends CustomPainter {
  BreathingRingPainter({
    required this.progress,
    required this.arcColor,
    required this.trackColor,
    required this.glowIntensity,
    this.strokeWidth = 5.0,
  });

  final double progress;
  final Color arcColor;
  final Color trackColor;
  final double glowIntensity;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - strokeWidth;

    // 1. Inner radial glow — deeper ambient fill
    final glowRadius = radius * 0.92;
    final glowOpacity = (0.06 + 0.16 * glowIntensity).clamp(0.0, 1.0);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          arcColor.withValues(alpha: glowOpacity),
          arcColor.withValues(alpha: glowOpacity * 0.3),
          arcColor.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: glowRadius));
    canvas.drawCircle(center, glowRadius, glowPaint);

    // 2. Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // 3. Progress arc with soft glow halo
    if (progress > 0) {
      // Arc glow (wider, softer behind the arc)
      final arcGlowPaint = Paint()
        ..color = arcColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      final sweepAngle = progress * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        arcGlowPaint,
      );

      // Arc itself
      final arcPaint = Paint()
        ..color = arcColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(BreathingRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.arcColor != arcColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
