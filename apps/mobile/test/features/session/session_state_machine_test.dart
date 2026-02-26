import 'package:clearbreath/features/session/domain/session_phase.dart';
import 'package:clearbreath/features/session/domain/session_plan.dart';
import 'package:clearbreath/features/session/domain/session_state_machine.dart';
import 'package:clearbreath/features/techniques/domain/technique_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('countdown transitions into inhale', () {
    final preset = PhasePreset(
      id: 'beginner',
      label: 'Beginner',
      recommendedDurationsMinutes: const [5],
      inhaleMs: 1000,
      holdMs: 1000,
      exhaleMs: 1000,
      holdAfterExhaleMs: 0,
    );

    final machine = SessionStateMachine(
      plan: SessionPlan.fromPreset(preset, 60),
      countdown: const Duration(seconds: 3),
    );

    machine.start();
    expect(machine.state.phase, SessionPhase.countdown);
    expect(machine.state.phaseRemaining, const Duration(seconds: 3));
    expect(machine.state.totalElapsed, Duration.zero);

    machine.tick(const Duration(seconds: 1));
    expect(machine.state.phase, SessionPhase.countdown);
    expect(machine.state.phaseRemaining, const Duration(seconds: 2));
    expect(machine.state.totalElapsed, Duration.zero);

    machine.tick(const Duration(seconds: 2));
    expect(machine.state.phase, SessionPhase.inhale);
    expect(machine.state.phaseRemaining, const Duration(milliseconds: 1000));
    expect(machine.state.totalElapsed, Duration.zero);
  });

  test('phase techniques cycle and count breaths', () {
    final preset = PhasePreset(
      id: 'beginner',
      label: 'Beginner',
      recommendedDurationsMinutes: const [5],
      inhaleMs: 1000,
      holdMs: 1000,
      exhaleMs: 1000,
      holdAfterExhaleMs: 1000,
    );

    final machine = SessionStateMachine(
      plan: SessionPlan.fromPreset(preset, 60),
      countdown: Duration.zero,
    );

    machine.start();
    expect(machine.state.phase, SessionPhase.inhale);
    expect(machine.state.breathsCompleted, 0);
    expect(machine.state.totalElapsed, Duration.zero);

    machine.tick(const Duration(milliseconds: 1000));
    expect(machine.state.phase, SessionPhase.hold);
    expect(machine.state.totalElapsed, const Duration(milliseconds: 1000));

    machine.tick(const Duration(milliseconds: 1000));
    expect(machine.state.phase, SessionPhase.exhale);
    expect(machine.state.totalElapsed, const Duration(milliseconds: 2000));

    machine.tick(const Duration(milliseconds: 1000));
    expect(machine.state.phase, SessionPhase.holdAfterExhale);
    expect(machine.state.totalElapsed, const Duration(milliseconds: 3000));

    machine.tick(const Duration(milliseconds: 1000));
    expect(machine.state.phase, SessionPhase.inhale);
    expect(machine.state.breathsCompleted, 1);
    expect(machine.state.totalElapsed, const Duration(milliseconds: 4000));
  });

  test('skips phases with zero durations', () {
    final preset = PhasePreset(
      id: 'beginner',
      label: 'Beginner',
      recommendedDurationsMinutes: const [5],
      inhaleMs: 1000,
      holdMs: 0,
      exhaleMs: 1000,
      holdAfterExhaleMs: 0,
    );

    final machine = SessionStateMachine(
      plan: SessionPlan.fromPreset(preset, 60),
      countdown: Duration.zero,
    );

    machine.start();
    expect(machine.state.phase, SessionPhase.inhale);

    machine.tick(const Duration(milliseconds: 1000));
    expect(machine.state.phase, SessionPhase.exhale);

    machine.tick(const Duration(milliseconds: 1000));
    expect(machine.state.phase, SessionPhase.inhale);
  });

  test('pause freezes progression until resume', () {
    final preset = PhasePreset(
      id: 'beginner',
      label: 'Beginner',
      recommendedDurationsMinutes: const [5],
      inhaleMs: 10000,
      holdMs: 0,
      exhaleMs: 0,
      holdAfterExhaleMs: 0,
    );

    final machine = SessionStateMachine(
      plan: SessionPlan.fromPreset(preset, 60),
      countdown: Duration.zero,
    );

    machine.start();
    expect(machine.state.phase, SessionPhase.inhale);

    machine.tick(const Duration(milliseconds: 1000));
    expect(machine.state.phase, SessionPhase.inhale);
    expect(machine.state.phaseRemaining, const Duration(milliseconds: 9000));
    expect(machine.state.totalElapsed, const Duration(milliseconds: 1000));

    machine.pause();
    expect(machine.state.phase, SessionPhase.paused);

    machine.tick(const Duration(milliseconds: 5000));
    expect(machine.state.phase, SessionPhase.paused);
    expect(machine.state.phaseRemaining, const Duration(milliseconds: 9000));
    expect(machine.state.totalElapsed, const Duration(milliseconds: 1000));

    machine.resume();
    expect(machine.state.phase, SessionPhase.inhale);

    machine.tick(const Duration(milliseconds: 1000));
    expect(machine.state.phase, SessionPhase.inhale);
    expect(machine.state.phaseRemaining, const Duration(milliseconds: 8000));
    expect(machine.state.totalElapsed, const Duration(milliseconds: 2000));
  });

  test('duration limit auto-completes', () {
    final preset = PhasePreset(
      id: 'beginner',
      label: 'Beginner',
      recommendedDurationsMinutes: const [5],
      inhaleMs: 1000,
      holdMs: 0,
      exhaleMs: 1000,
      holdAfterExhaleMs: 0,
    );

    final machine = SessionStateMachine(
      plan: SessionPlan.fromPreset(preset, 5),
      countdown: Duration.zero,
    );

    machine.start();
    machine.tick(const Duration(seconds: 10));
    expect(machine.state.isCompleted, isTrue);
    expect(machine.state.totalElapsed, const Duration(seconds: 5));
    expect(machine.state.phaseRemaining, Duration.zero);
    expect(machine.state.breathsCompleted, 2);
  });

  test('round plan progresses with rest and counts beats', () {
    final preset = BpmRoundsPreset(
      id: 'beginner',
      label: 'Beginner',
      recommendedDurationsMinutes: const [5],
      bpm: 60,
      rounds: 3,
      roundSeconds: 2,
      restSeconds: 1,
    );

    final machine = SessionStateMachine(
      plan: SessionPlan.fromPreset(preset, preset.naturalDurationSeconds),
      countdown: Duration.zero,
    );

    machine.start();
    expect(machine.state.phase, SessionPhase.round);
    expect(machine.state.currentRound, 1);
    expect(machine.state.totalRounds, 3);
    expect(machine.state.breathsCompleted, 0);

    machine.tick(const Duration(seconds: 1));
    expect(machine.state.phase, SessionPhase.round);
    expect(machine.state.breathsCompleted, 1);
    expect(machine.state.totalElapsed, const Duration(seconds: 1));

    machine.tick(const Duration(seconds: 1));
    expect(machine.state.phase, SessionPhase.rest);
    expect(machine.state.breathsCompleted, 2);
    expect(machine.state.totalElapsed, const Duration(seconds: 2));

    machine.tick(const Duration(seconds: 1));
    expect(machine.state.phase, SessionPhase.round);
    expect(machine.state.currentRound, 2);
    expect(machine.state.totalRounds, 3);
    expect(machine.state.totalElapsed, const Duration(seconds: 3));

    machine.tick(const Duration(seconds: 2));
    expect(machine.state.phase, SessionPhase.rest);
    expect(machine.state.totalElapsed, const Duration(seconds: 5));
    expect(machine.state.breathsCompleted, 4);
    expect(machine.state.currentRound, 2);

    machine.tick(const Duration(seconds: 1));
    expect(machine.state.phase, SessionPhase.round);
    expect(machine.state.currentRound, 3);
    expect(machine.state.totalRounds, 3);
    expect(machine.state.totalElapsed, const Duration(seconds: 6));

    machine.tick(const Duration(seconds: 2));
    expect(machine.state.isCompleted, isTrue);
    expect(machine.state.totalElapsed, const Duration(seconds: 8));
    expect(machine.state.breathsCompleted, 6);
    expect(machine.state.currentRound, 3);
  });

  test('alternate nostril switches sides per cycle', () {
    final preset = PhasePreset(
      id: 'beginner',
      label: 'Beginner',
      recommendedDurationsMinutes: const [5],
      inhaleMs: 1000,
      holdMs: 0,
      exhaleMs: 1000,
      holdAfterExhaleMs: 0,
    );

    final machine = SessionStateMachine(
      plan: SessionPlan.fromPreset(preset, 10, alternateNostril: true),
      countdown: Duration.zero,
    );

    machine.start();
    expect(machine.state.phase, SessionPhase.inhale);
    expect(machine.state.activeNostril, NostrilSide.left);

    machine.tick(const Duration(seconds: 1));
    expect(machine.state.phase, SessionPhase.exhale);
    expect(machine.state.activeNostril, NostrilSide.right);

    machine.tick(const Duration(seconds: 1));
    expect(machine.state.phase, SessionPhase.inhale);
    expect(machine.state.activeNostril, NostrilSide.right);

    machine.tick(const Duration(seconds: 1));
    expect(machine.state.phase, SessionPhase.exhale);
    expect(machine.state.activeNostril, NostrilSide.left);
  });

  test('uneven tick deltas preserve total elapsed time', () {
    final preset = PhasePreset(
      id: 'beginner',
      label: 'Beginner',
      recommendedDurationsMinutes: const [5],
      inhaleMs: 4000,
      holdMs: 4000,
      exhaleMs: 4000,
      holdAfterExhaleMs: 4000,
    );

    final machine = SessionStateMachine(
      plan: SessionPlan.fromPreset(preset, 20),
      countdown: Duration.zero,
    );

    machine.start();

    const pattern = [
      Duration(milliseconds: 17),
      Duration(milliseconds: 33),
      Duration(milliseconds: 51),
    ];

    var total = Duration.zero;
    var index = 0;
    while (total < const Duration(seconds: 20)) {
      final next = pattern[index % pattern.length];
      final remaining = const Duration(seconds: 20) - total;
      final step = next <= remaining ? next : remaining;
      machine.tick(step);
      total += step;
      index += 1;
    }

    expect(machine.state.isCompleted, isTrue);
    expect(machine.state.totalElapsed, const Duration(seconds: 20));
  });
}
