import 'package:flutter/foundation.dart';

import '../../techniques/domain/technique_preset.dart';
import 'session_phase.dart';

enum NostrilSide { left, right }

@immutable
sealed class SessionPlan {
  const SessionPlan({required this.totalDuration});

  final Duration totalDuration;

  factory SessionPlan.fromPreset(
    TechniquePreset preset,
    int durationLimitSeconds, {
    bool alternateNostril = false,
  }) {
    final totalDuration = Duration(seconds: durationLimitSeconds);

    if (preset is PhasePreset) {
      final durations = <SessionPhase, Duration>{
        SessionPhase.inhale: Duration(milliseconds: preset.inhaleMs),
        SessionPhase.hold: Duration(milliseconds: preset.holdMs),
        SessionPhase.exhale: Duration(milliseconds: preset.exhaleMs),
        SessionPhase.holdAfterExhale:
            Duration(milliseconds: preset.holdAfterExhaleMs),
      };

      final sequence = <SessionPhase>[
        for (final phase in _breathingPhases)
          if ((durations[phase] ?? Duration.zero) > Duration.zero) phase,
      ];

      final cycleDuration = sequence.fold<Duration>(
        Duration.zero,
        (sum, phase) => sum + (durations[phase] ?? Duration.zero),
      );

      final totalCycles = _ceilUnits(totalDuration, cycleDuration);
      final nostrils = alternateNostril
          ? List<NostrilSide>.generate(
              totalCycles,
              (index) => index.isEven ? NostrilSide.left : NostrilSide.right,
              growable: false,
            )
          : null;

      return PhaseSessionPlan(
        phaseSequence: sequence,
        phaseDurations: durations,
        totalCycles: totalCycles,
        totalDuration: totalDuration,
        nostrilByCycle: nostrils,
      );
    }

    if (preset is BpmRoundsPreset) {
      final roundDuration = Duration(seconds: preset.roundSeconds);
      final restDuration = Duration(seconds: preset.restSeconds);
      final cycleDuration = roundDuration + restDuration;
      final rounds = _ceilUnits(totalDuration, cycleDuration);

      return RoundSessionPlan(
        bpm: preset.bpm,
        rounds: rounds,
        roundDuration: roundDuration,
        restDuration: restDuration,
        totalDuration: totalDuration,
      );
    }

    throw StateError('Unsupported preset type: ${preset.runtimeType}');
  }
}

@immutable
final class PhaseSessionPlan extends SessionPlan {
  PhaseSessionPlan({
    required List<SessionPhase> phaseSequence,
    required Map<SessionPhase, Duration> phaseDurations,
    required this.totalCycles,
    required super.totalDuration,
    required this.nostrilByCycle,
  }) : phaseSequence = List.unmodifiable(phaseSequence),
       phaseDurations = Map.unmodifiable(phaseDurations);

  final List<SessionPhase> phaseSequence;
  final Map<SessionPhase, Duration> phaseDurations;
  final int totalCycles;
  final List<NostrilSide>? nostrilByCycle;
}

@immutable
final class RoundSessionPlan extends SessionPlan {
  const RoundSessionPlan({
    required this.bpm,
    required this.rounds,
    required this.roundDuration,
    required this.restDuration,
    required super.totalDuration,
  });

  final int bpm;
  final int rounds;
  final Duration roundDuration;
  final Duration restDuration;
}

int _ceilUnits(Duration total, Duration unit) {
  if (total <= Duration.zero) {
    return 0;
  }
  if (unit <= Duration.zero) {
    return 0;
  }
  final totalUs = total.inMicroseconds;
  final unitUs = unit.inMicroseconds;
  return (totalUs / unitUs).ceil().clamp(1, 1 << 30);
}

const _breathingPhases = [
  SessionPhase.inhale,
  SessionPhase.hold,
  SessionPhase.exhale,
  SessionPhase.holdAfterExhale,
];

