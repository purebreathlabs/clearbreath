import 'dart:math';

import 'session_phase.dart';
import 'session_plan.dart';
import 'session_state.dart';

class SessionStateMachine {
  SessionStateMachine({
    required SessionPlan plan,
    Duration countdown = const Duration(seconds: 3),
    String? techniqueId,
    String? presetId,
  }) : _plan = plan,
       _countdown = countdown,
       _techniqueId = techniqueId,
       _presetId = presetId;

  final SessionPlan _plan;
  final Duration _countdown;
  final String? _techniqueId;
  final String? _presetId;

  SessionPhase _phase = SessionPhase.idle;
  Duration _phaseRemaining = Duration.zero;
  Duration _totalElapsed = Duration.zero;
  int _breathsCompleted = 0;
  SessionPhase? _pausedFrom;

  int _cycleIndex = 0;
  int? _currentRound;
  int? _totalRounds;
  NostrilSide? _activeNostril;

  int _phaseIndex = 0;
  Duration _beatCarry = Duration.zero;

  SessionState get state => SessionState(
    phase: _phase,
    phaseRemaining: _phaseRemaining,
    totalElapsed: _totalElapsed,
    breathsCompleted: _breathsCompleted,
    techniqueId: _techniqueId,
    presetId: _presetId,
    currentRound: _currentRound,
    totalRounds: _totalRounds,
    activeNostril: _activeNostril,
    pausedFrom: _pausedFrom,
  );

  void start() {
    _phaseRemaining = Duration.zero;
    _totalElapsed = Duration.zero;
    _breathsCompleted = 0;
    _pausedFrom = null;
    _cycleIndex = 0;
    _phaseIndex = 0;
    _currentRound = null;
    _totalRounds = null;
    _activeNostril = null;
    _beatCarry = Duration.zero;

    if (_plan.totalDuration <= Duration.zero) {
      _phase = SessionPhase.completed;
      return;
    }

    if (_countdown > Duration.zero) {
      _phase = SessionPhase.countdown;
      _phaseRemaining = _countdown;
      return;
    }

    _startActive();
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
    _activeNostril = null;
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
    _activeNostril = _nostrilForPhase(_phase);
  }

  void stop({bool completed = false}) {
    _pausedFrom = null;
    _activeNostril = null;

    if (completed) {
      _phase = SessionPhase.completed;
      _phaseRemaining = Duration.zero;
      return;
    }

    _phase = SessionPhase.idle;
    _phaseRemaining = Duration.zero;
    _totalElapsed = Duration.zero;
    _breathsCompleted = 0;
    _cycleIndex = 0;
    _phaseIndex = 0;
    _currentRound = null;
    _totalRounds = null;
    _beatCarry = Duration.zero;
  }

  List<SessionPhase> tick(Duration delta) {
    if (delta <= Duration.zero) {
      return const [];
    }
    if (_phase == SessionPhase.idle ||
        _phase == SessionPhase.paused ||
        _phase == SessionPhase.completed) {
      return const [];
    }

    var remaining = delta;
    var guard = 0;
    final transitions = <SessionPhase>[];

    while (remaining > Duration.zero &&
        _phase != SessionPhase.idle &&
        _phase != SessionPhase.paused &&
        _phase != SessionPhase.completed) {
      guard += 1;
      if (guard > 2000) {
        stop();
        transitions.add(_phase);
        return transitions;
      }

      if (_phase == SessionPhase.countdown) {
        final consumed = _consume(remaining);
        remaining -= consumed;
        if (_phaseRemaining == Duration.zero) {
          _startActive();
          transitions.add(_phase);
        }
        continue;
      }

      final before = _phase;
      final consumed = _consume(remaining);
      remaining -= consumed;
      var used = consumed;
      if (_plan.totalDuration > Duration.zero) {
        final allowance = _plan.totalDuration - _totalElapsed;
        if (allowance <= Duration.zero) {
          _totalElapsed = _plan.totalDuration;
          stop(completed: true);
          transitions.add(SessionPhase.completed);
          return transitions;
        }
        if (used > allowance) {
          used = allowance;
        }
      }

      _totalElapsed += used;

      if (before == SessionPhase.round) {
        _applyBeatCount(used);
      }

      if (_plan.totalDuration > Duration.zero &&
          _totalElapsed >= _plan.totalDuration) {
        _totalElapsed = _plan.totalDuration;
        stop(completed: true);
        transitions.add(SessionPhase.completed);
        return transitions;
      }

      if (_phaseRemaining == Duration.zero) {
        _advancePhase();
        transitions.add(_phase);
      }
    }

    return transitions;
  }

  void _startActive() {
    _activeNostril = null;

    final plan = _plan;
    if (plan is PhaseSessionPlan) {
      if (plan.phaseSequence.isEmpty) {
        stop(completed: true);
        return;
      }

      _phaseIndex = 0;
      _phase = plan.phaseSequence[0];
      _phaseRemaining = plan.phaseDurations[_phase] ?? Duration.zero;
      _currentRound = null;
      _totalRounds = null;
      _activeNostril = _nostrilForPhase(_phase);
      return;
    }

    if (plan is RoundSessionPlan) {
      if (plan.roundDuration == Duration.zero && plan.restDuration == Duration.zero) {
        stop(completed: true);
        return;
      }

      _phase = plan.roundDuration > Duration.zero
          ? SessionPhase.round
          : SessionPhase.rest;
      _phaseRemaining =
          _phase == SessionPhase.round ? plan.roundDuration : plan.restDuration;
      _currentRound = plan.rounds > 0 ? 1 : null;
      _totalRounds = plan.rounds > 0 ? plan.rounds : null;
      _beatCarry = Duration.zero;
      if (_phaseRemaining == Duration.zero) {
        _advancePhase();
      }
      return;
    }

    stop(completed: true);
  }

  void _advancePhase() {
    _activeNostril = null;

    final plan = _plan;
    if (plan is PhaseSessionPlan) {
      final sequence = plan.phaseSequence;
      if (sequence.isEmpty) {
        stop(completed: true);
        return;
      }

      final previous = _phase;
      _phaseIndex = (_phaseIndex + 1) % sequence.length;
      if (_phaseIndex == 0 && previous != SessionPhase.countdown) {
        _breathsCompleted += 1;
        _cycleIndex += 1;
      }

      _phase = sequence[_phaseIndex];
      _phaseRemaining = plan.phaseDurations[_phase] ?? Duration.zero;
      _activeNostril = _nostrilForPhase(_phase);
      return;
    }

    if (plan is RoundSessionPlan) {
      if (plan.roundDuration == Duration.zero && plan.restDuration == Duration.zero) {
        stop(completed: true);
        return;
      }

      for (var i = 0; i < 4; i += 1) {
        if (_phase == SessionPhase.round) {
          _phase = SessionPhase.rest;
          _phaseRemaining = plan.restDuration;
          _beatCarry = Duration.zero;
        } else if (_phase == SessionPhase.rest) {
          final current = _currentRound;
          if (current != null) {
            _currentRound = current + 1;
          }
          _phase = SessionPhase.round;
          _phaseRemaining = plan.roundDuration;
          _beatCarry = Duration.zero;
        } else {
          stop(completed: true);
          return;
        }

        if (_phaseRemaining > Duration.zero) {
          return;
        }
      }

      stop(completed: true);
      return;
    }

    stop(completed: true);
  }

  void _applyBeatCount(Duration consumed) {
    final plan = _plan;
    if (plan is! RoundSessionPlan) {
      return;
    }

    final bpm = plan.bpm;
    if (bpm <= 0) {
      return;
    }

    final intervalUs = (60000000 / bpm).round();
    if (intervalUs <= 0) {
      return;
    }

    final interval = Duration(microseconds: intervalUs);
    _beatCarry += consumed;

    var guard = 0;
    while (_beatCarry >= interval) {
      guard += 1;
      if (guard > 10000) {
        _beatCarry = Duration.zero;
        return;
      }
      _beatCarry -= interval;
      _breathsCompleted += 1;
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

  NostrilSide? _nostrilForPhase(SessionPhase phase) {
    final plan = _plan;
    if (plan is! PhaseSessionPlan) {
      return null;
    }

    final nostrils = plan.nostrilByCycle;
    if (nostrils == null || nostrils.isEmpty) {
      return null;
    }

    final inhaleSide = nostrils[_cycleIndex % nostrils.length];
    return switch (phase) {
      SessionPhase.inhale => inhaleSide,
      SessionPhase.exhale => inhaleSide == NostrilSide.left
          ? NostrilSide.right
          : NostrilSide.left,
      _ => null,
    };
  }
}
