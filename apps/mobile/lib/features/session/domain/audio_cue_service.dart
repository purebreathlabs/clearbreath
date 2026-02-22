import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

abstract class AudioCueService {
  bool get isMuted;
  double get volume;

  void setVolume(double value);
  void mute();
  void unmute();

  Future<void> playInhaleCue();
  Future<void> playExhaleCue();
  Future<void> playHoldCue();
  Future<void> playTick();
  Future<void> playComplete();

  Future<void> dispose();
}

final audioCueServiceProvider = Provider<AudioCueService>((ref) {
  final service = Platform.environment.containsKey('FLUTTER_TEST')
      ? const _NoopAudioCueService()
      : _JustAudioCueService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

class _JustAudioCueService implements AudioCueService {
  final AudioPlayer _cuePlayer = AudioPlayer();
  final AudioPlayer _tickPlayer = AudioPlayer();

  String? _currentCueAsset;
  bool _tickLoaded = false;

  bool _muted = false;
  double _volume = 1.0;

  @override
  bool get isMuted => _muted;

  @override
  double get volume => _volume;

  @override
  void setVolume(double value) {
    _volume = value.clamp(0.0, 1.0);
    _applyVolume();
  }

  @override
  void mute() {
    if (_muted) {
      return;
    }
    _muted = true;
    _applyVolume();
  }

  @override
  void unmute() {
    if (!_muted) {
      return;
    }
    _muted = false;
    _applyVolume();
  }

  void _applyVolume() {
    final value = _muted ? 0.0 : _volume;
    unawaited(_cuePlayer.setVolume(value));
    unawaited(_tickPlayer.setVolume(value));
  }

  @override
  Future<void> playInhaleCue() => _playCue('assets/audio/inhale_cue.mp3');

  @override
  Future<void> playExhaleCue() => _playCue('assets/audio/exhale_cue.mp3');

  @override
  Future<void> playHoldCue() => _playCue('assets/audio/hold_cue.mp3');

  @override
  Future<void> playComplete() => _playCue('assets/audio/session_complete.mp3');

  @override
  Future<void> playTick() async {
    try {
      if (!_tickLoaded) {
        await _tickPlayer.setAsset('assets/audio/tick.mp3');
        _tickLoaded = true;
        _applyVolume();
      }
      await _tickPlayer.seek(Duration.zero);
      await _tickPlayer.play();
    } catch (_) {}
  }

  Future<void> _playCue(String assetPath) async {
    try {
      if (_currentCueAsset != assetPath) {
        await _cuePlayer.setAsset(assetPath);
        _currentCueAsset = assetPath;
        _applyVolume();
      } else {
        await _cuePlayer.seek(Duration.zero);
      }
      await _cuePlayer.play();
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    await _cuePlayer.dispose();
    await _tickPlayer.dispose();
  }
}

class _NoopAudioCueService implements AudioCueService {
  const _NoopAudioCueService();

  @override
  bool get isMuted => true;

  @override
  double get volume => 0.0;

  @override
  void mute() {}

  @override
  void setVolume(double value) {}

  @override
  void unmute() {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playComplete() async {}

  @override
  Future<void> playExhaleCue() async {}

  @override
  Future<void> playHoldCue() async {}

  @override
  Future<void> playInhaleCue() async {}

  @override
  Future<void> playTick() async {}
}

