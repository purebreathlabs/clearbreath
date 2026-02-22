import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/session_phase.dart';
import '../../domain/session_plan.dart';
import 'breathing_circle.dart';

class AlternateNostrilIndicator extends StatelessWidget {
  const AlternateNostrilIndicator({
    super.key,
    required this.activeNostril,
    required this.phase,
    required this.phaseRemaining,
    required this.phaseDuration,
  });

  final NostrilSide? activeNostril;
  final SessionPhase phase;
  final Duration phaseRemaining;
  final Duration phaseDuration;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    Widget chip(String label, bool active) {
      return Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? colors.textPrimary : colors.surface,
          borderRadius: BorderRadius.circular(components.buttonRadius),
          border: Border.all(color: colors.border),
        ),
        child: Text(
          label,
          style: typography.titleMedium.copyWith(
            color: active ? colors.background : colors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      );
    }

    final leftActive = activeNostril == NostrilSide.left;
    final rightActive = activeNostril == NostrilSide.right;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            chip('L', leftActive),
            SizedBox(width: spacing.lg),
            chip('R', rightActive),
          ],
        ),
        SizedBox(height: spacing.xl),
        SizedBox(
          height: 260,
          child: BreathingCircle(
            phase: phase,
            phaseRemaining: phaseRemaining,
            phaseDuration: phaseDuration,
          ),
        ),
      ],
    );
  }
}

