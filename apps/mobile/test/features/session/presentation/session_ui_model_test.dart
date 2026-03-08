import 'package:clearbreath/features/session/domain/session_phase.dart';
import 'package:clearbreath/features/session/domain/session_state.dart';
import 'package:clearbreath/features/session/presentation/session_ui_model.dart';
import 'package:clearbreath/features/techniques/domain/technique.dart';
import 'package:clearbreath/features/techniques/domain/technique_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SessionState makeState({
    SessionPhase phase = SessionPhase.inhale,
    Duration phaseRemaining = const Duration(seconds: 2),
    Duration totalElapsed = const Duration(seconds: 10),
    int? currentRound,
    int? totalRounds,
  }) {
    return SessionState(
      phase: phase,
      phaseRemaining: phaseRemaining,
      totalElapsed: totalElapsed,
      breathsCompleted: 0,
      techniqueId: 'box',
      currentRound: currentRound,
      totalRounds: totalRounds,
    );
  }

  group('phaseTitle', () {
    test('inhale', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.inhale), null, null);
      expect(model.phaseTitle, 'INHALE');
    });

    test('exhale', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.exhale), null, null);
      expect(model.phaseTitle, 'EXHALE');
    });

    test('hold', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.hold), null, null);
      expect(model.phaseTitle, 'HOLD');
    });

    test('holdAfterExhale', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.holdAfterExhale), null, null);
      expect(model.phaseTitle, 'HOLD');
    });

    test('rest', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.rest), null, null);
      expect(model.phaseTitle, 'REST');
    });

    test('round', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.round), null, null);
      expect(model.phaseTitle, 'BREATHE');
    });

    test('countdown', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.countdown), null, null);
      expect(model.phaseTitle, 'READY');
    });

    test('paused', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.paused), null, null);
      expect(model.phaseTitle, 'PAUSED');
    });

    test('completed', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.completed), null, null);
      expect(model.phaseTitle, 'COMPLETE');
    });
  });

  group('roundLabel', () {
    test('null when no round info', () {
      final model = SessionUiModel.from(makeState(), null, null);
      expect(model.roundLabel, isNull);
    });

    test('present when round info available', () {
      final model = SessionUiModel.from(
        makeState(currentRound: 2, totalRounds: 3),
        null,
        null,
      );
      expect(model.roundLabel, 'Round 2 of 3');
    });

    test('null when only currentRound present', () {
      final model = SessionUiModel.from(
        makeState(currentRound: 1),
        null,
        null,
      );
      expect(model.roundLabel, isNull);
    });
  });

  group('timer formatting', () {
    test('primaryTimer formats phase remaining', () {
      final model = SessionUiModel.from(
        makeState(phaseRemaining: const Duration(seconds: 65)),
        null,
        null,
      );
      expect(model.primaryTimer, '01:05');
    });

    test('secondaryTimer formats elapsed with prefix', () {
      final model = SessionUiModel.from(
        makeState(totalElapsed: const Duration(seconds: 128)),
        null,
        null,
      );
      expect(model.secondaryTimer, 'Elapsed 02:08');
    });
  });

  group('phaseProgress', () {
    test('computes progress from remaining and preset', () {
      final preset = PhasePreset(
        id: 'test',
        label: 'Test',
        recommendedDurationsMinutes: const [5],
        inhaleMs: 4000,
        holdMs: 4000,
        exhaleMs: 4000,
        holdAfterExhaleMs: 4000,
      );

      final model = SessionUiModel.from(
        makeState(
          phase: SessionPhase.inhale,
          phaseRemaining: const Duration(seconds: 2),
        ),
        null,
        preset,
      );
      expect(model.phaseProgress, closeTo(0.5, 0.01));
    });

    test('clamps to 0-1 range', () {
      final model = SessionUiModel.from(
        makeState(phaseRemaining: Duration.zero),
        null,
        null,
      );
      expect(model.phaseProgress, greaterThanOrEqualTo(0.0));
      expect(model.phaseProgress, lessThanOrEqualTo(1.0));
    });
  });

  group('isHoldPhase', () {
    test('true for hold', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.hold), null, null);
      expect(model.isHoldPhase, isTrue);
    });

    test('true for holdAfterExhale', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.holdAfterExhale), null, null);
      expect(model.isHoldPhase, isTrue);
    });

    test('false for inhale', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.inhale), null, null);
      expect(model.isHoldPhase, isFalse);
    });
  });

  group('stageMode', () {
    test('falls back to metronome for kapalbhati', () {
      final state = SessionState(
        phase: SessionPhase.round,
        phaseRemaining: const Duration(seconds: 2),
        totalElapsed: Duration.zero,
        breathsCompleted: 0,
        techniqueId: 'kapalbhati',
      );
      final model = SessionUiModel.from(state, null, null);
      expect(model.stageMode, AnimationMode.metronome);
    });

    test('falls back to alternateNostril for anulom_vilom', () {
      final state = SessionState(
        phase: SessionPhase.inhale,
        phaseRemaining: const Duration(seconds: 2),
        totalElapsed: Duration.zero,
        breathsCompleted: 0,
        techniqueId: 'anulom_vilom',
      );
      final model = SessionUiModel.from(state, null, null);
      expect(model.stageMode, AnimationMode.alternateNostril);
    });

    test('defaults to circle', () {
      final model = SessionUiModel.from(makeState(), null, null);
      expect(model.stageMode, AnimationMode.circle);
    });
  });

  group('showPhaseTitle', () {
    test('true when breathing', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.inhale), null, null);
      expect(model.showPhaseTitle, isTrue);
    });

    test('true when paused', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.paused), null, null);
      expect(model.showPhaseTitle, isTrue);
    });

    test('true when countdown', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.countdown), null, null);
      expect(model.showPhaseTitle, isTrue);
    });

    test('false when idle', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.idle), null, null);
      expect(model.showPhaseTitle, isFalse);
    });

    test('false when completed', () {
      final model = SessionUiModel.from(makeState(phase: SessionPhase.completed), null, null);
      expect(model.showPhaseTitle, isFalse);
    });
  });
}
