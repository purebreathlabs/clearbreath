import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/session_phase.dart';

class SessionPhaseLabel extends StatelessWidget {
  const SessionPhaseLabel({super.key, required this.phase});

  final SessionPhase phase;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;

    final label = _labelFor(phase);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(
        label,
        key: ValueKey(label),
        style: typography.headlineLarge.copyWith(
          color: colors.textPrimary,
          letterSpacing: 1.8,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _labelFor(SessionPhase phase) {
    return switch (phase) {
      SessionPhase.inhale => 'INHALE',
      SessionPhase.hold || SessionPhase.holdAfterExhale => 'HOLD',
      SessionPhase.exhale => 'EXHALE',
      SessionPhase.round => 'EXHALE',
      SessionPhase.rest => 'REST',
      SessionPhase.countdown => 'READY',
      SessionPhase.paused => 'PAUSED',
      SessionPhase.completed => 'COMPLETE',
      _ => 'READY',
    };
  }
}
