import 'package:clearbreath/features/session/domain/active_session_config.dart';
import 'package:clearbreath/features/session/domain/local_session.dart';
import 'package:clearbreath/features/session/domain/session_phase.dart';
import 'package:clearbreath/features/session/domain/session_state.dart';
import 'package:clearbreath/features/techniques/domain/technique.dart';
import 'package:clearbreath/features/techniques/domain/technique_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Technique buildTechnique() {
    return Technique(
      id: 'box',
      name: 'Box',
      shortDescription: 'Box breathing.',
      animationMode: AnimationMode.circle,
      safety: const TechniqueSafety(requiresAck: false, title: '', body: ''),
      about: const TechniqueAbout(
        what: 'What',
        how: 'How',
        bestTime: 'Best',
        benefits: 'Benefits',
        warnings: 'Warnings',
      ),
      presets: {
        'beginner': PhasePreset(
          id: 'beginner',
          label: 'Beginner',
          recommendedDurationsMinutes: const [2, 5, 10, 20],
          inhaleMs: 4000,
          holdMs: 4000,
          exhaleMs: 4000,
          holdAfterExhaleMs: 4000,
        ),
      },
    );
  }

  test('fromCompleted computes expected fields', () {
    final startedAtUtc = DateTime.utc(2026, 2, 20, 10);
    final nowUtc = DateTime.utc(2026, 2, 20, 10, 5);

    final finalState = SessionState(
      phase: SessionPhase.completed,
      phaseRemaining: Duration.zero,
      totalElapsed: const Duration(minutes: 5),
      breathsCompleted: 42,
      techniqueId: 'box',
      presetId: 'beginner',
      currentRound: null,
      totalRounds: null,
      activeNostril: null,
      pausedFrom: null,
    );

    final session = LocalSession.fromCompleted(
      config: null,
      finalState: finalState,
      startedAtUtc: startedAtUtc,
      timezoneOffsetMinutes: -480,
      endedEarly: false,
      idGenerator: () => 'session-id',
      nowUtc: () => nowUtc,
    );

    expect(session.clientSessionId, equals('session-id'));
    expect(session.techniqueId, equals('box'));
    expect(session.presetId, equals('beginner'));
    expect(session.startedAtUtc, equals(startedAtUtc));
    expect(
      session.endedAtUtc,
      equals(startedAtUtc.add(const Duration(minutes: 5))),
    );
    expect(session.timezoneOffsetMinutes, equals(-480));
    expect(session.durationSecondsActual, equals(300));
    expect(session.breathsCompletedEstimated, equals(42));
    expect(session.endedEarly, isFalse);
    expect(session.syncedToCloud, isFalse);
    expect(session.createdAt, equals(nowUtc));
  });

  test('fromCompleted prefers active session config when available', () {
    final technique = buildTechnique();
    final preset = technique.presets['beginner']!;

    final config = ActiveSessionConfig(
      technique: technique,
      preset: preset,
      presetId: 'beginner',
      durationLimitSeconds: 300,
    );

    final startedAtUtc = DateTime.utc(2026, 2, 20, 10);

    final finalState = SessionState(
      phase: SessionPhase.completed,
      phaseRemaining: Duration.zero,
      totalElapsed: const Duration(minutes: 5),
      breathsCompleted: 10,
      techniqueId: 'other',
      presetId: 'other',
      currentRound: null,
      totalRounds: null,
      activeNostril: null,
      pausedFrom: null,
    );

    final session = LocalSession.fromCompleted(
      config: config,
      finalState: finalState,
      startedAtUtc: startedAtUtc,
      timezoneOffsetMinutes: 0,
      endedEarly: false,
      idGenerator: () => 'session-id',
      nowUtc: () => DateTime.utc(2026, 2, 20, 10, 5),
    );

    expect(session.techniqueId, equals('box'));
    expect(session.presetId, equals('beginner'));
  });

  test('fromCompleted clamps negative elapsed', () {
    final startedAtUtc = DateTime.utc(2026, 2, 20, 10);

    final finalState = SessionState(
      phase: SessionPhase.completed,
      phaseRemaining: Duration.zero,
      totalElapsed: const Duration(seconds: -5),
      breathsCompleted: -1,
      techniqueId: 'box',
      presetId: 'beginner',
      currentRound: null,
      totalRounds: null,
      activeNostril: null,
      pausedFrom: null,
    );

    final session = LocalSession.fromCompleted(
      config: null,
      finalState: finalState,
      startedAtUtc: startedAtUtc,
      timezoneOffsetMinutes: 0,
      endedEarly: true,
      idGenerator: () => 'session-id',
      nowUtc: () => DateTime.utc(2026, 2, 20, 10),
    );

    expect(session.durationSecondsActual, equals(0));
    expect(session.breathsCompletedEstimated, equals(0));
    expect(session.endedAtUtc, equals(startedAtUtc));
    expect(session.endedEarly, isTrue);
  });
}
