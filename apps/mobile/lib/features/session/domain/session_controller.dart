import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/auth_state.dart';
import '../../auth/domain/auth_state_provider.dart';
import '../../background_audio/data/background_audio_controller.dart';
import '../../notifications/domain/notification_controller.dart';
import '../../stats/domain/stats_engine.dart';
import '../../stats/domain/weekly_minutes_provider.dart';
import '../../sync/domain/merged_stats_provider.dart';
import '../../sync/domain/sync_controller.dart';
import '../../techniques/domain/technique.dart';
import '../../techniques/domain/technique_preset.dart';
import '../data/session_repository.dart';
import 'active_session_config.dart';
import 'audio_cue_service.dart';
import 'haptic_service.dart';
import 'local_session.dart';
import 'session_phase.dart';
import 'session_plan.dart';
import 'session_state.dart';
import 'session_state_machine.dart';
import 'session_tick_source.dart';
import 'wakelock_service.dart';

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

class SessionController extends Notifier<SessionState> {
  Timer? _timer;
  SessionStateMachine? _machine;
  late final SessionTickSource _tickSource;
  late final AudioCueService _audio;
  late final HapticService _haptics;
  late final WakelockService _wakelock;
  late final BackgroundAudioController _backgroundAudio;
  late final SessionRepository _sessions;
  StreamSubscription<BackgroundAudioEvent>? _backgroundEventsSub;
  bool _pausedByInterruption = false;
  ActiveSessionConfig? _activeConfig;
  DateTime? _startedAtUtc;
  int _timezoneOffsetMinutes = 0;
  bool _sessionSaved = false;

  @override
  SessionState build() {
    ref.onDispose(_dispose);
    _tickSource = ref.read(sessionTickSourceProvider);
    _audio = ref.read(audioCueServiceProvider);
    _haptics = ref.read(hapticServiceProvider);
    _wakelock = ref.read(wakelockServiceProvider);
    _backgroundAudio = ref.read(backgroundAudioControllerProvider);
    _sessions = ref.read(sessionRepositoryProvider);

    _backgroundEventsSub = _backgroundAudio.events.listen(
      _handleBackgroundEvent,
    );
    return SessionState.idle();
  }

  void startDefault() {
    stop();
    _pausedByInterruption = false;
    _activeConfig = null;
    _startedAtUtc = DateTime.now().toUtc();
    _timezoneOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    _sessionSaved = false;

    final preset = PhasePreset(
      id: 'beginner',
      label: 'Beginner',
      recommendedDurationsMinutes: const [5],
      inhaleMs: 4000,
      holdMs: 4000,
      exhaleMs: 4000,
      holdAfterExhaleMs: 4000,
    );

    final plan = SessionPlan.fromPreset(preset, 5 * 60);

    final machine = SessionStateMachine(
      plan: plan,
      techniqueId: 'box',
      presetId: 'beginner',
    );
    machine.start();
    _machine = machine;
    state = machine.state;

    unawaited(_wakelock.enable());
    unawaited(_backgroundAudio.start(techniqueName: 'Box'));

    _tickSource.reset();
    _tickSource.start();

    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) => _tick());
  }

  void startSession(ActiveSessionConfig config) {
    stop();
    _pausedByInterruption = false;
    _activeConfig = config;
    _startedAtUtc = DateTime.now().toUtc();
    _timezoneOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    _sessionSaved = false;

    final plan = SessionPlan.fromPreset(
      config.preset,
      config.durationLimitSeconds,
      alternateNostril:
          config.technique.animationMode == AnimationMode.alternateNostril,
    );

    final machine = SessionStateMachine(
      plan: plan,
      techniqueId: config.technique.id,
      presetId: config.presetId,
    );

    machine.start();
    _machine = machine;
    state = machine.state;

    unawaited(_wakelock.enable());
    unawaited(_backgroundAudio.start(techniqueName: config.technique.name));

    _tickSource.reset();
    _tickSource.start();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) => _tick());
  }

  void pause() {
    _pausedByInterruption = false;
    final machine = _machine;
    if (machine == null) {
      return;
    }
    machine.pause();
    _stopTicker();
    _tickSource.stop();
    state = machine.state;
    unawaited(_backgroundAudio.setPlaying(false));
  }

  void resume() {
    _pausedByInterruption = false;
    final machine = _machine;
    if (machine == null) {
      return;
    }
    machine.resume();
    state = machine.state;
    if (!state.isPaused && (state.isBreathing || state.isCountdown)) {
      _tickSource.start();
      _timer ??= Timer.periodic(
        const Duration(milliseconds: 50),
        (_) => _tick(),
      );
    }
    unawaited(_backgroundAudio.setPlaying(true));
  }

  void stop() {
    _pausedByInterruption = false;
    _stopTicker();
    _machine?.stop(completed: false);
    _machine = null;
    _tickSource.reset();
    state = SessionState.idle();
    unawaited(_wakelock.disable());
    unawaited(_backgroundAudio.stop());
    _activeConfig = null;
    _startedAtUtc = null;
  }

  Future<void> endEarly() async {
    _pausedByInterruption = false;
    final machine = _machine;
    final startedAtUtc = _startedAtUtc;
    if (machine != null && startedAtUtc != null && !_sessionSaved) {
      _sessionSaved = true;
      final local = LocalSession.fromCompleted(
        config: _activeConfig,
        finalState: machine.state,
        startedAtUtc: startedAtUtc,
        timezoneOffsetMinutes: _timezoneOffsetMinutes,
        endedEarly: true,
      );
      try {
        await _sessions.insert(local);
        ref.invalidate(localStatsProvider);
        await ref.read(localStatsProvider.future);
        ref.invalidate(mergedStatsProvider);
        ref.invalidate(weeklyMinutesProvider);
        if (ref.read(authStateProvider) is AuthStateSignedIn) {
          unawaited(
            ref.read(syncControllerProvider.notifier).submitSession(local),
          );
        }
      } catch (_) {}
    }
    stop();
  }

  void _tick() {
    final machine = _machine;
    if (machine == null) {
      return;
    }
    final before = machine.state;
    final delta = _tickSource.delta();
    final transitions = machine.tick(delta);
    final after = machine.state;

    if (transitions.isNotEmpty) {
      for (final phase in transitions) {
        if (phase == SessionPhase.completed) {
          continue;
        }
        _handlePhaseTransition(phase);
      }
    }

    if (transitions.contains(SessionPhase.completed)) {
      _handleCompleted(after);
    }

    final breathDelta = after.breathsCompleted - before.breathsCompleted;
    if (breathDelta > 0 && before.phase == SessionPhase.round) {
      unawaited(_audio.playTick());
      unawaited(_haptics.tick());
    }

    state = after;
    if (after.isCompleted) {
      _stopTicker();
      _tickSource.stop();
    }
  }

  void _stopTicker() {
    _timer?.cancel();
    _timer = null;
  }

  void _handlePhaseTransition(SessionPhase phase) {
    if (phase == SessionPhase.inhale) {
      unawaited(_audio.playInhaleCue());
      unawaited(_haptics.phaseTransition());
      return;
    }

    if (phase == SessionPhase.exhale) {
      unawaited(_audio.playExhaleCue());
      unawaited(_haptics.phaseTransition());
      return;
    }

    if (phase == SessionPhase.hold ||
        phase == SessionPhase.holdAfterExhale ||
        phase == SessionPhase.rest) {
      unawaited(_audio.playHoldCue());
      unawaited(_haptics.phaseTransition());
      return;
    }

    if (phase == SessionPhase.round) {
      unawaited(_haptics.phaseTransition());
    }
  }

  void _handleCompleted(SessionState finalState) {
    if (_sessionSaved) {
      return;
    }
    _sessionSaved = true;

    final startedAtUtc = _startedAtUtc;
    if (startedAtUtc != null) {
      final local = LocalSession.fromCompleted(
        config: _activeConfig,
        finalState: finalState,
        startedAtUtc: startedAtUtc,
        timezoneOffsetMinutes: _timezoneOffsetMinutes,
        endedEarly: false,
      );
      unawaited(_persistCompletion(local));
    }

    unawaited(_audio.playComplete());
    unawaited(_haptics.sessionComplete());
    unawaited(_wakelock.disable());
    unawaited(_backgroundAudio.stop());
  }

  Future<void> _persistCompletion(LocalSession local) async {
    try {
      await _sessions.insert(local);
    } catch (_) {}

    ref.invalidate(localStatsProvider);
    await ref.read(localStatsProvider.future);
    ref.invalidate(mergedStatsProvider);
    ref.invalidate(weeklyMinutesProvider);
    ref.read(latestXpAwardsProvider.notifier).clear();
    ref.read(lastCompletedSessionProvider.notifier).set(local);
    unawaited(
      ref.read(notificationControllerProvider.notifier).onSessionCompleted(),
    );

    if (ref.read(authStateProvider) is AuthStateSignedIn) {
      unawaited(ref.read(syncControllerProvider.notifier).submitSession(local));
    }
  }

  void _handleBackgroundEvent(BackgroundAudioEvent event) {
    if (event is BackgroundAudioPauseRequested) {
      pause();
      return;
    }

    if (event is BackgroundAudioPlayRequested) {
      resume();
      return;
    }

    if (event is BackgroundAudioStopRequested) {
      unawaited(endEarly());
      return;
    }

    if (event is BackgroundAudioInterruptionBegan) {
      if (_pausedByInterruption) {
        return;
      }
      if (!state.canPause) {
        return;
      }
      _pausedByInterruption = true;
      final machine = _machine;
      if (machine == null) {
        return;
      }
      machine.pause();
      _stopTicker();
      _tickSource.stop();
      state = machine.state;
      unawaited(_backgroundAudio.setPlaying(false));
      return;
    }

    if (event is BackgroundAudioInterruptionEnded) {
      if (!_pausedByInterruption) {
        return;
      }
      _pausedByInterruption = false;
      resume();
    }
  }

  void _dispose() {
    _timer?.cancel();
    _timer = null;
    _tickSource.reset();
    unawaited(_wakelock.disable());
    unawaited(_backgroundAudio.stop());
    unawaited(_backgroundEventsSub?.cancel());
  }
}
