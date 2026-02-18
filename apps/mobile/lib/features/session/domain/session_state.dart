import 'package:flutter/foundation.dart';

import 'session_phase.dart';

@immutable
class SessionState {
  const SessionState({
    required this.phase,
    required this.phaseRemaining,
    required this.totalElapsed,
    this.pausedFrom,
  });

  factory SessionState.idle() {
    return const SessionState(
      phase: SessionPhase.idle,
      phaseRemaining: Duration.zero,
      totalElapsed: Duration.zero,
    );
  }

  final SessionPhase phase;
  final Duration phaseRemaining;
  final Duration totalElapsed;
  final SessionPhase? pausedFrom;

  bool get isIdle => phase == SessionPhase.idle;
  bool get isPaused => phase == SessionPhase.paused;
  bool get isCountdown => phase == SessionPhase.countdown;

  bool get isBreathing {
    return switch (phase) {
      SessionPhase.inhale ||
      SessionPhase.hold ||
      SessionPhase.exhale ||
      SessionPhase.holdAfterExhale => true,
      _ => false,
    };
  }

  bool get canStart => isIdle;
  bool get canPause => isBreathing || isCountdown;
  bool get canResume => isPaused;
  bool get canStop => isBreathing || isCountdown || isPaused;
}
