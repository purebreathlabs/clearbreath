import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/session_phase.dart';

class BreathingCircle extends StatefulWidget {
  const BreathingCircle({
    super.key,
    required this.phase,
    required this.phaseRemaining,
    required this.phaseDuration,
  });

  final SessionPhase phase;
  final Duration phaseRemaining;
  final Duration phaseDuration;

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
    if (oldWidget.phase != widget.phase) {
      _syncPulse();
    }
  }

  void _syncPulse() {
    if (_isHoldPhase(widget.phase)) {
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

    final progress = _phaseProgress(
      widget.phaseRemaining,
      widget.phaseDuration,
    );
    final scale = _scaleFor(widget.phase, progress);
    final label = _labelForPhase(widget.phase);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);

        return Center(
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              final glow = _isHoldPhase(widget.phase) ? _pulse.value : 0.0;
              final shadowOpacity = (0.10 + 0.20 * glow).clamp(0.0, 1.0);

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.textPrimary,
                      width: 2,
                    ),
                    boxShadow: _isHoldPhase(widget.phase)
                        ? [
                            BoxShadow(
                              color: colors.textPrimary.withAlpha(
                                (shadowOpacity * 255).round().clamp(0, 255).toInt(),
                              ),
                              blurRadius: 32,
                              spreadRadius: 2,
                            ),
                          ]
                        : const [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: typography.titleLarge.copyWith(
                      color: colors.textPrimary,
                      letterSpacing: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  double _phaseProgress(Duration remaining, Duration total) {
    if (total <= Duration.zero) {
      return 1.0;
    }
    final t = 1 - remaining.inMicroseconds / total.inMicroseconds;
    return t.clamp(0.0, 1.0);
  }

  bool _isHoldPhase(SessionPhase phase) {
    return phase == SessionPhase.hold || phase == SessionPhase.holdAfterExhale;
  }

  double _scaleFor(SessionPhase phase, double progress) {
    return switch (phase) {
      SessionPhase.inhale => lerpDouble(0.3, 1.0, progress) ?? 1.0,
      SessionPhase.exhale => lerpDouble(1.0, 0.3, progress) ?? 1.0,
      SessionPhase.hold => 1.0,
      SessionPhase.holdAfterExhale => 0.3,
      _ => 0.3,
    };
  }

  String _labelForPhase(SessionPhase phase) {
    return switch (phase) {
      SessionPhase.inhale => 'INHALE',
      SessionPhase.hold || SessionPhase.holdAfterExhale => 'HOLD',
      SessionPhase.exhale => 'EXHALE',
      SessionPhase.rest => 'REST',
      SessionPhase.round => 'EXHALE',
      SessionPhase.countdown => 'READY',
      SessionPhase.paused => 'PAUSED',
      SessionPhase.completed => 'COMPLETE',
      _ => 'READY',
    };
  }
}
