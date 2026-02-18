import 'package:clearbreath/features/session/domain/session_phase.dart';
import 'package:clearbreath/features/session/domain/session_preset.dart';
import 'package:clearbreath/features/session/domain/session_state_machine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('countdown transitions into inhale', () {
    final machine = SessionStateMachine(
      preset: const SessionPreset(inhaleMs: 1000, holdMs: 1000, exhaleMs: 1000),
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

  test('box breathing cycles inhale hold exhale holdAfterExhale', () {
    final machine = SessionStateMachine(
      preset: const SessionPreset(
        inhaleMs: 1000,
        holdMs: 1000,
        exhaleMs: 1000,
        holdAfterExhaleMs: 1000,
      ),
      countdown: Duration.zero,
    );

    machine.start();
    expect(machine.state.phase, SessionPhase.inhale);

    machine.tick(const Duration(milliseconds: 1000));
    expect(machine.state.phase, SessionPhase.hold);

    machine.tick(const Duration(milliseconds: 1000));
    expect(machine.state.phase, SessionPhase.exhale);

    machine.tick(const Duration(milliseconds: 1000));
    expect(machine.state.phase, SessionPhase.holdAfterExhale);

    machine.tick(const Duration(milliseconds: 1000));
    expect(machine.state.phase, SessionPhase.inhale);
  });

  test('skips holdAfterExhale when duration is zero', () {
    final machine = SessionStateMachine(
      preset: const SessionPreset(
        inhaleMs: 1000,
        holdMs: 1000,
        exhaleMs: 1000,
        holdAfterExhaleMs: 0,
      ),
      countdown: Duration.zero,
    );

    machine.start();
    expect(machine.state.phase, SessionPhase.inhale);

    machine.tick(const Duration(milliseconds: 1000));
    expect(machine.state.phase, SessionPhase.hold);

    machine.tick(const Duration(milliseconds: 1000));
    expect(machine.state.phase, SessionPhase.exhale);

    machine.tick(const Duration(milliseconds: 1000));
    expect(machine.state.phase, SessionPhase.inhale);
  });

  test('skips hold when duration is zero', () {
    final machine = SessionStateMachine(
      preset: const SessionPreset(
        inhaleMs: 1000,
        holdMs: 0,
        exhaleMs: 1000,
        holdAfterExhaleMs: 0,
      ),
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
    final machine = SessionStateMachine(
      preset: const SessionPreset(
        inhaleMs: 10000,
        holdMs: 0,
        exhaleMs: 0,
        holdAfterExhaleMs: 0,
      ),
      countdown: Duration.zero,
    );

    machine.start();
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

  test('uneven tick deltas preserve total elapsed time', () {
    final machine = SessionStateMachine(
      preset: const SessionPreset(
        inhaleMs: 4000,
        holdMs: 4000,
        exhaleMs: 4000,
        holdAfterExhaleMs: 4000,
      ),
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

    expect(machine.state.totalElapsed, const Duration(seconds: 20));
  });
}
