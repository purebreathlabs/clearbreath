import 'dart:ui';

import '../../techniques/domain/technique.dart';
import '../../techniques/domain/technique_preset.dart';
import '../domain/session_phase.dart';
import '../domain/session_state.dart';
import 'phase_colors.dart';

class SessionUiModel {
  const SessionUiModel({
    required this.phaseTitle,
    required this.primaryTimer,
    required this.secondaryTimer,
    required this.roundLabel,
    required this.stageMode,
    required this.phaseProgress,
    required this.phaseColor,
    required this.phase,
    required this.phaseDuration,
    required this.phaseRemaining,
    required this.isPaused,
    required this.isHoldPhase,
    required this.showPhaseTitle,
    required this.canPause,
    required this.canResume,
    required this.canStop,
  });

  factory SessionUiModel.from(
    SessionState state,
    Technique? technique,
    TechniquePreset? preset,
  ) {
    final phaseDuration = _phaseDurationFor(state, preset);
    final progress = _computeProgress(state.phaseRemaining, phaseDuration);

    return SessionUiModel(
      phaseTitle: _phaseTitle(state.phase),
      primaryTimer: _formatDuration(state.phaseRemaining),
      secondaryTimer: 'Elapsed ${_formatDuration(state.totalElapsed)}',
      roundLabel: _roundLabel(state.currentRound, state.totalRounds),
      stageMode: technique?.animationMode ?? _fallbackMode(state.techniqueId),
      phaseProgress: progress,
      phaseColor: PhaseColors.forPhase(state.phase),
      phase: state.phase,
      phaseDuration: phaseDuration,
      phaseRemaining: state.phaseRemaining,
      isPaused: state.isPaused,
      isHoldPhase:
          state.phase == SessionPhase.hold ||
          state.phase == SessionPhase.holdAfterExhale,
      showPhaseTitle: state.isBreathing || state.isCountdown || state.isPaused,
      canPause: state.canPause,
      canResume: state.canResume,
      canStop: state.canStop,
    );
  }

  final String phaseTitle;
  final String primaryTimer;
  final String secondaryTimer;
  final String? roundLabel;
  final AnimationMode stageMode;
  final double phaseProgress;
  final Color phaseColor;
  final SessionPhase phase;
  final Duration phaseDuration;
  final Duration phaseRemaining;
  final bool isPaused;
  final bool isHoldPhase;
  final bool showPhaseTitle;
  final bool canPause;
  final bool canResume;
  final bool canStop;

  static String _phaseTitle(SessionPhase phase) {
    return switch (phase) {
      SessionPhase.inhale => 'INHALE',
      SessionPhase.hold || SessionPhase.holdAfterExhale => 'HOLD',
      SessionPhase.exhale => 'EXHALE',
      SessionPhase.round => 'BREATHE',
      SessionPhase.rest => 'REST',
      SessionPhase.countdown => 'READY',
      SessionPhase.paused => 'PAUSED',
      SessionPhase.completed => 'COMPLETE',
      _ => 'READY',
    };
  }

  static String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds.abs();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  static String? _roundLabel(int? currentRound, int? totalRounds) {
    if (currentRound == null || totalRounds == null) {
      return null;
    }
    return 'Round $currentRound of $totalRounds';
  }

  static double _computeProgress(Duration remaining, Duration total) {
    if (total <= Duration.zero) {
      return 1.0;
    }
    final t = 1 - remaining.inMicroseconds / total.inMicroseconds;
    return t.clamp(0.0, 1.0);
  }

  static Duration _phaseDurationFor(
    SessionState state,
    TechniquePreset? preset,
  ) {
    if (state.phase == SessionPhase.countdown) {
      return const Duration(seconds: 3);
    }

    if (preset is PhasePreset) {
      return switch (state.phase) {
        SessionPhase.inhale => Duration(milliseconds: preset.inhaleMs),
        SessionPhase.hold => Duration(milliseconds: preset.holdMs),
        SessionPhase.exhale => Duration(milliseconds: preset.exhaleMs),
        SessionPhase.holdAfterExhale => Duration(
          milliseconds: preset.holdAfterExhaleMs,
        ),
        _ => const Duration(seconds: 1),
      };
    }

    if (preset is BpmRoundsPreset) {
      return switch (state.phase) {
        SessionPhase.round => Duration(seconds: preset.roundSeconds),
        SessionPhase.rest => Duration(seconds: preset.restSeconds),
        _ => const Duration(seconds: 1),
      };
    }

    return const Duration(seconds: 1);
  }

  static AnimationMode _fallbackMode(String? techniqueId) {
    return switch (techniqueId) {
      'kapalbhati' || 'bhastrika' => AnimationMode.metronome,
      'anulom_vilom' => AnimationMode.alternateNostril,
      _ => AnimationMode.circle,
    };
  }
}
