import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/session_phase.dart';

class MetronomePulse extends StatefulWidget {
  const MetronomePulse({
    super.key,
    required this.bpm,
    required this.phase,
    required this.phaseRemaining,
    required this.phaseDuration,
    required this.currentRound,
    required this.totalRounds,
  });

  final int bpm;
  final SessionPhase phase;
  final Duration phaseRemaining;
  final Duration phaseDuration;
  final int? currentRound;
  final int? totalRounds;

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
    if (oldWidget.bpm != widget.bpm || oldWidget.phase != widget.phase) {
      _syncController();
    }
  }

  void _syncController() {
    final beat = _beatDuration(widget.bpm);
    if (beat == null || widget.phase != SessionPhase.round) {
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
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    final roundLabel = _roundLabel(widget.currentRound, widget.totalRounds);

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = min(constraints.maxWidth, constraints.maxHeight);
        final dotBase = (available * 0.18).clamp(20.0, 34.0);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (roundLabel != null)
                Text(
                  roundLabel,
                  key: const Key('metronome_round_label'),
                  style: typography.titleMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              if (roundLabel != null) SizedBox(height: spacing.lg),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = Curves.easeOut.transform(_controller.value);
                  final scale = widget.phase == SessionPhase.round
                      ? 0.6 + 0.5 * t
                      : 0.6;

                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: dotBase,
                  height: dotBase,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: spacing.xl),
              if (widget.phase == SessionPhase.rest)
                Text(
                  _formatDuration(widget.phaseRemaining),
                  key: const Key('metronome_rest_remaining'),
                  style: typography.displayMedium.copyWith(
                    color: colors.textPrimary,
                  ),
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

  String? _roundLabel(int? currentRound, int? totalRounds) {
    if (currentRound == null || totalRounds == null) {
      return null;
    }
    return 'Round $currentRound of $totalRounds';
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds.abs();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}
