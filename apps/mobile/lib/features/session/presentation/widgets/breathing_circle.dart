import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import 'breathing_ring_painter.dart';

class BreathingCircle extends StatefulWidget {
  const BreathingCircle({
    super.key,
    required this.progress,
    required this.isHoldPhase,
    required this.phaseTitle,
    required this.primaryTimer,
  });

  final double progress;
  final bool isHoldPhase;
  final String phaseTitle;
  final String primaryTimer;

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(BreathingCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isHoldPhase != widget.isHoldPhase) {
      _syncPulse();
    }
  }

  void _syncPulse() {
    if (widget.isHoldPhase) {
      if (!_pulse.isAnimating) {
        _pulse.repeat(reverse: true);
      }
      return;
    }
    if (_pulse.isAnimating) {
      _pulse.stop();
    }
    _pulse.value = 0;
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size =
            min(constraints.maxWidth, constraints.maxHeight).clamp(0.0, 280.0);

        return Center(
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              final glow = widget.isHoldPhase ? _pulse.value : 0.0;

              return SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: BreathingRingPainter(
                    progress: widget.progress,
                    arcColor: colors.textPrimary,
                    trackColor: colors.border,
                    glowIntensity: glow,
                  ),
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
                ),
              );
            },
          ),
        );
      },
    );
  }
}
