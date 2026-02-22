import 'package:clearbreath/features/session/domain/session_phase.dart';
import 'package:clearbreath/features/session/domain/session_plan.dart';
import 'package:clearbreath/features/techniques/domain/technique_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('phase preset builds phase plan with expected sequence and cycles', () {
    final preset = PhasePreset(
      id: 'beginner',
      label: 'Beginner',
      recommendedDurationsMinutes: const [5],
      inhaleMs: 1000,
      holdMs: 500,
      exhaleMs: 1000,
      holdAfterExhaleMs: 0,
    );

    final plan = SessionPlan.fromPreset(preset, 10);

    expect(plan, isA<PhaseSessionPlan>());
    final phasePlan = plan as PhaseSessionPlan;
    expect(phasePlan.phaseSequence, const [
      SessionPhase.inhale,
      SessionPhase.hold,
      SessionPhase.exhale,
    ]);
    expect(phasePlan.totalCycles, 4);
    expect(phasePlan.totalDuration, const Duration(seconds: 10));
    expect(phasePlan.nostrilByCycle, isNull);
  });

  test('alternate nostril phase plan includes nostril mapping', () {
    final preset = PhasePreset(
      id: 'beginner',
      label: 'Beginner',
      recommendedDurationsMinutes: const [5],
      inhaleMs: 1000,
      holdMs: 0,
      exhaleMs: 1000,
      holdAfterExhaleMs: 0,
    );

    final plan = SessionPlan.fromPreset(preset, 5, alternateNostril: true);

    expect(plan, isA<PhaseSessionPlan>());
    final phasePlan = plan as PhaseSessionPlan;
    expect(phasePlan.totalCycles, 3);
    expect(phasePlan.nostrilByCycle, const [
      NostrilSide.left,
      NostrilSide.right,
      NostrilSide.left,
    ]);
  });

  test('bpm rounds preset builds round plan with expected rounds', () {
    final preset = BpmRoundsPreset(
      id: 'beginner',
      label: 'Beginner',
      recommendedDurationsMinutes: const [5],
      bpm: 60,
      rounds: 3,
      roundSeconds: 30,
      restSeconds: 30,
    );

    final plan = SessionPlan.fromPreset(preset, 90);

    expect(plan, isA<RoundSessionPlan>());
    final roundPlan = plan as RoundSessionPlan;
    expect(roundPlan.bpm, 60);
    expect(roundPlan.rounds, 2);
    expect(roundPlan.roundDuration, const Duration(seconds: 30));
    expect(roundPlan.restDuration, const Duration(seconds: 30));
    expect(roundPlan.totalDuration, const Duration(seconds: 90));
  });
}
