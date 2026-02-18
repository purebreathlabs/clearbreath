import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class SessionTickSource {
  void start();
  void stop();
  void reset();
  Duration delta();
}

final sessionTickSourceProvider = Provider<SessionTickSource>(
  (ref) => RealSessionTickSource(),
);

class RealSessionTickSource implements SessionTickSource {
  final Stopwatch _stopwatch = Stopwatch();
  Duration _last = Duration.zero;

  @override
  void start() {
    if (_stopwatch.isRunning) {
      return;
    }
    _stopwatch.start();
    _last = _stopwatch.elapsed;
  }

  @override
  void stop() {
    _stopwatch.stop();
  }

  @override
  void reset() {
    _stopwatch
      ..stop()
      ..reset();
    _last = Duration.zero;
  }

  @override
  Duration delta() {
    if (!_stopwatch.isRunning) {
      return Duration.zero;
    }
    final now = _stopwatch.elapsed;
    var out = now - _last;
    if (out.isNegative) {
      out = Duration.zero;
    }
    _last = now;
    return out;
  }
}

class FixedSessionTickSource implements SessionTickSource {
  FixedSessionTickSource(this.interval);

  final Duration interval;
  bool _running = false;

  @override
  void start() {
    _running = true;
  }

  @override
  void stop() {
    _running = false;
  }

  @override
  void reset() {
    _running = false;
  }

  @override
  Duration delta() {
    if (!_running) {
      return Duration.zero;
    }
    return interval;
  }
}
