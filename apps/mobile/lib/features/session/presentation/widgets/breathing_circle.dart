import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/session_phase.dart';
import 'breathing_ring_painter.dart';

class BreathingCircle extends StatefulWidget {
  const BreathingCircle({
    super.key,
    required this.progress,
    required this.isHoldPhase,
    required this.phaseTitle,
    required this.primaryTimer,
    required this.arcColor,
    required this.phase,
    required this.phaseDuration,
    required this.phaseRemaining,
    required this.isPaused,
  });

  final double progress;
  final bool isHoldPhase;
  final String phaseTitle;
  final String primaryTimer;
  final Color arcColor;
  final SessionPhase phase;
  final Duration phaseDuration;
  final Duration phaseRemaining;
  final bool isPaused;

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _arc;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _arc = AnimationController(vsync: this, value: widget.progress);
    _syncPulse();
    _syncArc(phaseChanged: false);
  }

  @override
  void didUpdateWidget(BreathingCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isHoldPhase != widget.isHoldPhase) {
      _syncPulse();
    }

    final phaseChanged = widget.phase != oldWidget.phase;

    _syncArc(phaseChanged: phaseChanged);
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

  void _syncArc({required bool phaseChanged}) {
    if (widget.isPaused) {
      _arc.stop();
      return;
    }

    if (phaseChanged) {
      // Phase changed - snap to new start, then animate to 1.0
      _arc.value = widget.progress;
      _animateToEnd();
      return;
    }

    // Same phase - check for drift
    if (!_arc.isAnimating) {
      // Controller stopped (e.g. after resume), restart
      _arc.value = widget.progress;
      _animateToEnd();
      return;
    }

    // Resync if drift exceeds threshold
    final drift = (_arc.value - widget.progress).abs();
    if (drift > 0.04) {
      _arc.value = widget.progress;
      _animateToEnd();
    }
  }

  void _animateToEnd() {
    if (widget.phaseRemaining <= Duration.zero) {
      _arc.value = 1.0;
      return;
    }
    _arc.animateTo(1.0, duration: widget.phaseRemaining, curve: Curves.linear);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _arc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(
          constraints.maxWidth,
          constraints.maxHeight,
        ).clamp(0.0, 280.0);

        return Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulse, _arc]),
            builder: (context, child) {
              final glow = widget.isHoldPhase ? _pulse.value : 0.0;

              return TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: widget.arcColor),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                builder: (context, color, child) {
                  return SizedBox(
                    width: size,
                    height: size,
                    child: CustomPaint(
                      painter: BreathingRingPainter(
                        progress: _arc.value,
                        arcColor: color!,
                        trackColor: colors.border,
                        glowIntensity: glow,
                      ),
                      child: child,
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
        );
      },
    );
  }
}
