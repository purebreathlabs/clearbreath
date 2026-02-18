import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_extensions.dart';
import '../domain/session_controller.dart';
import '../domain/session_phase.dart';
import '../domain/session_state.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;

    final state = ref.watch(sessionControllerProvider);
    final controller = ref.read(sessionControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Session')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _phaseLabel(state),
                key: const Key('session_phase_label'),
                style: typography.headlineLarge.copyWith(
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.sm),
              if (state.isCountdown)
                Text(
                  _countdownLabel(state.phaseRemaining),
                  key: const Key('session_countdown_value'),
                  style: typography.displayLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  _formatDuration(state.phaseRemaining),
                  key: const Key('session_phase_remaining'),
                  style: typography.displayLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: spacing.xl),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _metricRow(
                        label: 'Total elapsed',
                        value: _formatDuration(state.totalElapsed),
                        typography: typography,
                        colors: colors,
                      ),
                      SizedBox(height: spacing.sm),
                      _metricRow(
                        label: 'Phase remaining',
                        value: _formatDuration(state.phaseRemaining),
                        typography: typography,
                        colors: colors,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: state.canStart
                          ? controller.startDefault
                          : state.canResume
                          ? controller.resume
                          : state.canPause
                          ? controller.pause
                          : null,
                      child: Text(_primaryButtonLabel(state)),
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.canStop ? controller.stop : null,
                      child: const Text('Stop'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricRow({
    required String label,
    required String value,
    required AppTypographyTokens typography,
    required AppColorTokens colors,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: typography.bodyLarge.copyWith(color: colors.textSecondary),
          ),
        ),
        Text(
          value,
          style: typography.bodyLarge.copyWith(color: colors.textPrimary),
        ),
      ],
    );
  }

  String _primaryButtonLabel(SessionState state) {
    if (state.canStart) {
      return 'Start';
    }
    if (state.canResume) {
      return 'Resume';
    }
    if (state.canPause) {
      return 'Pause';
    }
    return 'Start';
  }

  String _phaseLabel(SessionState state) {
    return switch (state.phase) {
      SessionPhase.idle => 'Ready',
      SessionPhase.countdown => 'Countdown',
      SessionPhase.inhale => 'Inhale',
      SessionPhase.hold => 'Hold',
      SessionPhase.exhale => 'Exhale',
      SessionPhase.holdAfterExhale => 'Hold',
      SessionPhase.paused => 'Paused',
      SessionPhase.completed => 'Complete',
    };
  }

  String _countdownLabel(Duration remaining) {
    final seconds = (remaining.inMilliseconds / 1000).ceil().clamp(0, 99);
    return '$seconds';
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
