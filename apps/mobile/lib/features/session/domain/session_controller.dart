import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_preset.dart';
import 'session_state.dart';
import 'session_state_machine.dart';
import 'session_tick_source.dart';

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

class SessionController extends Notifier<SessionState> {
  Timer? _timer;
  SessionStateMachine? _machine;
  late final SessionTickSource _tickSource;

  @override
  SessionState build() {
    ref.onDispose(_dispose);
    _tickSource = ref.read(sessionTickSourceProvider);
    return SessionState.idle();
  }

  void startDefault() {
    stop();

    final machine = SessionStateMachine(
      preset: const SessionPreset(
        inhaleMs: 4000,
        holdMs: 4000,
        exhaleMs: 4000,
        holdAfterExhaleMs: 4000,
      ),
    );
    machine.start();
    _machine = machine;
    state = machine.state;

    _tickSource.reset();
    _tickSource.start();

    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) => _tick());
  }

  void pause() {
    final machine = _machine;
    if (machine == null) {
      return;
    }
    machine.pause();
    _stopTicker();
    _tickSource.stop();
    state = machine.state;
  }

  void resume() {
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
  }

  void stop() {
    _stopTicker();
    _machine?.stop();
    _machine = null;
    _tickSource.reset();
    state = SessionState.idle();
  }

  void _tick() {
    final machine = _machine;
    if (machine == null) {
      return;
    }
    final delta = _tickSource.delta();
    machine.tick(delta);
    state = machine.state;
  }

  void _stopTicker() {
    _timer?.cancel();
    _timer = null;
  }

  void _dispose() {
    _timer?.cancel();
    _timer = null;
    _tickSource.reset();
  }
}
