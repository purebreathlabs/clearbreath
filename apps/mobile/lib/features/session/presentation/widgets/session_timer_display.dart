import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';

class SessionTimerDisplay extends StatelessWidget {
  const SessionTimerDisplay({
    super.key,
    required this.phaseRemaining,
    required this.totalElapsed,
    required this.currentRound,
    required this.totalRounds,
  });

  final Duration phaseRemaining;
  final Duration totalElapsed;
  final int? currentRound;
  final int? totalRounds;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    final roundLabel = _roundLabel(currentRound, totalRounds);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (roundLabel != null)
          Text(
            roundLabel,
            key: const Key('session_round_label'),
            style: typography.bodyLarge.copyWith(
              color: colors.textSecondary,
            ),
          ),
        if (roundLabel != null) SizedBox(height: spacing.sm),
        Text(
          _formatDuration(phaseRemaining),
          key: const Key('session_phase_remaining'),
          style: typography.displayLarge.copyWith(
            color: colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing.sm),
        Text(
          'Elapsed ${_formatDuration(totalElapsed)}',
          key: const Key('session_total_elapsed'),
          style: typography.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
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

