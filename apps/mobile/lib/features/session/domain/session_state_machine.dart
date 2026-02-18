import 'dart:math';

import 'session_phase.dart';
import 'session_preset.dart';
import 'session_state.dart';

class SessionStateMachine {
  SessionStateMachine({
    required SessionPreset preset,
    Duration countdown = const Duration(seconds: 3),
  }) : _preset = preset,
       _countdown = countdown;

  final SessionPreset _preset;
  final Duration _countdown;

  SessionPhase _phase = SessionPhase.idle;
  Duration _phaseRemaining = Duration.zero;
  Duration _totalElapsed = Duration.zero;
  SessionPhase? _pausedFrom;

  SessionState get state => SessionState(
    phase: _phase,
    phaseRemaining: _phaseRemaining,
    totalElapsed: _totalElapsed,
    pausedFrom: _pausedFrom,
  );

  void start() {
    _totalElapsed = Duration.zero;
    _pausedFrom = null;

    if (_countdown > Duration.zero) {
      _phase = SessionPhase.countdown;
      _phaseRemaining = _countdown;
      return;
    }

    final first = _firstBreathingPhase();
    if (first == null) {
      _phase = SessionPhase.idle;
      _phaseRemaining = Duration.zero;
      return;
    }
    _phase = first;
    _phaseRemaining = _durationFor(first);
  }

  void pause() {
    if (_phase == SessionPhase.paused) {
      return;
    }
    if (_phase == SessionPhase.idle || _phase == SessionPhase.completed) {
      return;
    }
    _pausedFrom = _phase;
    _phase = SessionPhase.paused;
  }

  void resume() {
    if (_phase != SessionPhase.paused) {
      return;
    }
    final restore = _pausedFrom;
    _pausedFrom = null;
    if (restore == null) {
      stop();
      return;
    }
    _phase = restore;
  }

  void stop({bool completed = false}) {
    _pausedFrom = null;
    _phase = completed ? SessionPhase.completed : SessionPhase.idle;
    _phaseRemaining = Duration.zero;
    _totalElapsed = Duration.zero;
  }

  void tick(Duration delta) {
    if (delta <= Duration.zero) {
      return;
    }
    if (_phase == SessionPhase.idle ||
        _phase == SessionPhase.paused ||
        _phase == SessionPhase.completed) {
      return;
    }

    var remaining = delta;
    var guard = 0;
    while (remaining > Duration.zero &&
        _phase != SessionPhase.idle &&
        _phase != SessionPhase.paused &&
        _phase != SessionPhase.completed) {
      guard += 1;
      if (guard > 1000) {
        stop();
        return;
      }

      if (_phase == SessionPhase.countdown) {
        final consumed = _consume(remaining);
        remaining -= consumed;
        if (_phaseRemaining == Duration.zero) {
          final first = _firstBreathingPhase();
          if (first == null) {
            stop();
            return;
          }
          _phase = first;
          _phaseRemaining = _durationFor(first);
        }
        continue;
      }

      final consumed = _consume(remaining);
      _totalElapsed += consumed;
      remaining -= consumed;
      if (_phaseRemaining == Duration.zero) {
        final next = _nextBreathingPhase(_phase);
        if (next == null) {
          stop(completed: true);
          return;
        }
        _phase = next;
        _phaseRemaining = _durationFor(next);
      }
    }
  }

  Duration _consume(Duration available) {
    final remainingUs = _phaseRemaining.inMicroseconds;
    if (remainingUs <= 0) {
      _phaseRemaining = Duration.zero;
      return Duration.zero;
    }

    final takeUs = min(available.inMicroseconds, remainingUs);
    final taken = Duration(microseconds: takeUs);
    _phaseRemaining -= taken;
    if (_phaseRemaining < Duration.zero) {
      _phaseRemaining = Duration.zero;
    }
    return taken;
  }

  SessionPhase? _firstBreathingPhase() {
    return _scanBreathingPhases(fromIndex: 0);
  }

  SessionPhase? _nextBreathingPhase(SessionPhase current) {
    final index = _breathingPhases.indexOf(current);
    if (index == -1) {
      return _firstBreathingPhase();
    }
    return _scanBreathingPhases(fromIndex: index + 1);
  }

  SessionPhase? _scanBreathingPhases({required int fromIndex}) {
    if (_breathingPhases.isEmpty) {
      return null;
    }
    for (var offset = 0; offset < _breathingPhases.length; offset += 1) {
      final index = (fromIndex + offset) % _breathingPhases.length;
      final phase = _breathingPhases[index];
      if (_durationFor(phase) > Duration.zero) {
        return phase;
      }
    }
    return null;
  }

  Duration _durationFor(SessionPhase phase) {
    final ms = switch (phase) {
      SessionPhase.inhale => _preset.inhaleMs,
      SessionPhase.hold => _preset.holdMs,
      SessionPhase.exhale => _preset.exhaleMs,
      SessionPhase.holdAfterExhale => _preset.holdAfterExhaleMs,
      _ => 0,
    };
    if (ms <= 0) {
      return Duration.zero;
    }
    return Duration(milliseconds: ms);
  }
}

const _breathingPhases = [
  SessionPhase.inhale,
  SessionPhase.hold,
  SessionPhase.exhale,
  SessionPhase.holdAfterExhale,
];
