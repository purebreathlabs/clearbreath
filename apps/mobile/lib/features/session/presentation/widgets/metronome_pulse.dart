import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import 'breathing_ring_painter.dart';

class MetronomePulse extends StatefulWidget {
  const MetronomePulse({
    super.key,
    required this.bpm,
    required this.progress,
    required this.isActiveRound,
    required this.phaseTitle,
    required this.primaryTimer,
    required this.roundLabel,
    required this.arcColor,
    this.maxRingSize = 240,
  });

  final int bpm;
  final double progress;
  final bool isActiveRound;
  final String phaseTitle;
  final String primaryTimer;
  final String? roundLabel;
  final Color arcColor;
  final double maxRingSize;

  @override
  State<MetronomePulse> createState() => _MetronomePulseState();
}

class _MetronomePulseState extends State<MetronomePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _syncController();
  }

  @override
  void didUpdateWidget(MetronomePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bpm != widget.bpm ||
        oldWidget.isActiveRound != widget.isActiveRound) {
      _syncController();
    }
  }

  void _syncController() {
    final beat = _beatDuration(widget.bpm);
    if (beat == null || !widget.isActiveRound) {
      _controller
        ..stop()
        ..duration = beat ?? const Duration(milliseconds: 600);
      _controller.value = 0;
      return;
    }

    _controller
      ..duration = beat
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final ringSize = min(
          constraints.maxWidth,
          widget.maxRingSize,
        ).clamp(0.0, 280.0);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Round label above the ring
              if (widget.roundLabel != null) ...[
                Text(
                  widget.roundLabel!,
                  style: typography.labelMedium.copyWith(
                    color: colors.textSecondary,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: spacing.md),
              ],

              // The ring — pulses during active round
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = widget.isActiveRound
                      ? Curves.easeOut.transform(_controller.value)
                      : 0.0;
                  final scale = widget.isActiveRound ? 0.96 + 0.04 * t : 1.0;
                  final glow = widget.isActiveRound ? t * 0.5 : 0.0;

                  return TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: widget.arcColor),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    builder: (context, color, child) {
                      return Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          width: ringSize,
                          height: ringSize,
                          child: CustomPaint(
                            painter: BreathingRingPainter(
                              progress: widget.progress,
                              arcColor: color!,
                              trackColor: colors.border,
                              glowIntensity: glow,
                            ),
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: Text(
                              widget.phaseTitle,
                              key: ValueKey(widget.phaseTitle),
                              style: typography.titleLarge.copyWith(
                                color: colors.textPrimary,
                                letterSpacing: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.primaryTimer,
                            style: typography.displayMedium.copyWith(
                              color: colors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Duration? _beatDuration(int bpm) {
    if (bpm <= 0) {
      return null;
    }
    final us = (60000000 / bpm).round();
    if (us <= 0) {
      return null;
    }
    return Duration(microseconds: us);
  }
}
