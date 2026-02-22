import 'package:flutter/foundation.dart';

import 'session_phase.dart';
import 'session_plan.dart';

@immutable
class SessionState {
  const SessionState({
    required this.phase,
    required this.phaseRemaining,
    required this.totalElapsed,
    required this.breathsCompleted,
    this.techniqueId,
    this.presetId,
    this.currentRound,
    this.totalRounds,
    this.activeNostril,
    this.pausedFrom,
  });

  factory SessionState.idle() {
    return const SessionState(
      phase: SessionPhase.idle,
      phaseRemaining: Duration.zero,
      totalElapsed: Duration.zero,
      breathsCompleted: 0,
    );
  }

  final SessionPhase phase;
  final Duration phaseRemaining;
  final Duration totalElapsed;
  final int breathsCompleted;
  final String? techniqueId;
  final String? presetId;
  final int? currentRound;
  final int? totalRounds;
  final NostrilSide? activeNostril;
  final SessionPhase? pausedFrom;

  bool get isIdle => phase == SessionPhase.idle;
  bool get isPaused => phase == SessionPhase.paused;
  bool get isCountdown => phase == SessionPhase.countdown;
  bool get isCompleted => phase == SessionPhase.completed;

  bool get isBreathing {
    return switch (phase) {
      SessionPhase.inhale ||
      SessionPhase.hold ||
      SessionPhase.exhale ||
      SessionPhase.holdAfterExhale ||
      SessionPhase.round ||
      SessionPhase.rest => true,
      _ => false,
    };
  }

  bool get canStart => isIdle;
  bool get canPause => isBreathing || isCountdown;
  bool get canResume => isPaused;
  bool get canStop => isBreathing || isCountdown || isPaused || isCompleted;
}
