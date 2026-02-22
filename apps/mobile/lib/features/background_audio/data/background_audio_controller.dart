import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

sealed class BackgroundAudioEvent {
  const BackgroundAudioEvent();
}

final class BackgroundAudioPlayRequested extends BackgroundAudioEvent {
  const BackgroundAudioPlayRequested();
}

final class BackgroundAudioPauseRequested extends BackgroundAudioEvent {
  const BackgroundAudioPauseRequested();
}

final class BackgroundAudioStopRequested extends BackgroundAudioEvent {
  const BackgroundAudioStopRequested();
}

final class BackgroundAudioInterruptionBegan extends BackgroundAudioEvent {
  const BackgroundAudioInterruptionBegan();
}

final class BackgroundAudioInterruptionEnded extends BackgroundAudioEvent {
  const BackgroundAudioInterruptionEnded();
}

abstract class BackgroundAudioController {
  Stream<BackgroundAudioEvent> get events;

  Future<void> start({required String techniqueName});
  Future<void> setPlaying(bool playing);
  Future<void> stop();
  Future<void> dispose();
}

final backgroundAudioControllerProvider = Provider<BackgroundAudioController>((
  ref,
) {
  final controller = Platform.environment.containsKey('FLUTTER_TEST')
      ? const _NoopBackgroundAudioController()
      : AudioServiceBackgroundAudioController();

  ref.onDispose(() => unawaited(controller.dispose()));
  return controller;
});

class AudioServiceBackgroundAudioController
    implements BackgroundAudioController {
  AudioServiceBackgroundAudioController({
    RemoteControls? remoteControls,
    Stream<AudioInterruptionEvent>? interruptionEvents,
    Stream<void>? becomingNoisyEvents,
    AudioPlayer? silencePlayer,
    bool enableAudioSession = true,
    bool enableSilentAudio = true,
  }) : _remoteControls = remoteControls,
       _interruptionEventsOverride = interruptionEvents,
       _becomingNoisyEventsOverride = becomingNoisyEvents,
       _silencePlayer = silencePlayer,
       _enableAudioSession = enableAudioSession,
       _enableSilentAudio = enableSilentAudio;

  final StreamController<BackgroundAudioEvent> _eventsController =
      StreamController.broadcast();

  final RemoteControls? _remoteControls;
  final Stream<AudioInterruptionEvent>? _interruptionEventsOverride;
  final Stream<void>? _becomingNoisyEventsOverride;
  final AudioPlayer? _silencePlayer;
  final bool _enableAudioSession;
  final bool _enableSilentAudio;

  RemoteControls? _remote;
  AudioSession? _session;

  StreamSubscription<String>? _remoteSub;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  StreamSubscription<void>? _becomingNoisySub;

  AudioPlayer? _ownedSilencePlayer;
  bool _silenceLoaded = false;
  bool _started = false;

  @override
  Stream<BackgroundAudioEvent> get events => _eventsController.stream;

  @override
  Future<void> start({required String techniqueName}) async {
    _started = true;
    await _ensureRemote();
    await _ensureSession();
    await _remote!.setMetadata(title: techniqueName);
    await _remote!.setPlaying(true);
    await _startSilentAudioIfNeeded();
  }

  @override
  Future<void> setPlaying(bool playing) async {
    if (!_started) {
      return;
    }
    try {
      await _ensureRemote();
      await _remote!.setPlaying(playing);
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    _started = false;
    try {
      await _remote?.shutdown();
    } catch (_) {}
    await _stopSilentAudio();
    await _cancelSubscriptions();
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _eventsController.close();
    try {
      await _ownedSilencePlayer?.dispose();
    } catch (_) {}
    await _remote?.dispose();
  }

  Future<void> _ensureRemote() async {
    final remote = _remote ??=
        (_remoteControls ?? _AudioServiceRemoteControls());
    await remote.ensureInitialized();
    _remoteSub ??= remote.commands.listen(_handleRemoteCommand);
  }

  Future<void> _ensureSession() async {
    if (!_enableAudioSession) {
      final interruptionStream = _interruptionEventsOverride;
      if (interruptionStream != null) {
        _interruptionSub ??= interruptionStream.listen(
          _handleInterruptionEvent,
        );
      }
      final noisyStream = _becomingNoisyEventsOverride;
      if (noisyStream != null) {
        _becomingNoisySub ??= noisyStream.listen((_) {
          _eventsController.add(const BackgroundAudioInterruptionBegan());
        });
      }
      return;
    }

    final session = _session ??= await AudioSession.instance;

    final base = const AudioSessionConfiguration.music();
    final config = base.copyWith(
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.mixWithOthers,
    );

    try {
      await session.configure(config);
      await session.setActive(true);
    } catch (_) {}

    final interruptionStream =
        _interruptionEventsOverride ?? session.interruptionEventStream;
    final noisyStream =
        _becomingNoisyEventsOverride ?? session.becomingNoisyEventStream;

    _interruptionSub ??= interruptionStream.listen(_handleInterruptionEvent);
    _becomingNoisySub ??= noisyStream.listen((_) {
      _eventsController.add(const BackgroundAudioInterruptionBegan());
    });
  }

  Future<void> _startSilentAudioIfNeeded() async {
    if (!_enableSilentAudio) {
      return;
    }

    final player = _silencePlayer ?? (_ownedSilencePlayer ??= AudioPlayer());
    try {
      if (!_silenceLoaded) {
        await player.setAsset('assets/audio/silence_loop.mp3');
        await player.setLoopMode(LoopMode.one);
        await player.setVolume(0.0);
        _silenceLoaded = true;
      }
      await player.play();
    } catch (_) {}
  }

  Future<void> _stopSilentAudio() async {
    final player = _silencePlayer ?? _ownedSilencePlayer;
    if (player == null) {
      return;
    }
    try {
      await player.stop();
    } catch (_) {}
  }

  Future<void> _cancelSubscriptions() async {
    await _remoteSub?.cancel();
    _remoteSub = null;

    await _interruptionSub?.cancel();
    _interruptionSub = null;

    await _becomingNoisySub?.cancel();
    _becomingNoisySub = null;
  }

  void _handleRemoteCommand(String command) {
    final event = switch (command) {
      'play' => const BackgroundAudioPlayRequested(),
      'pause' => const BackgroundAudioPauseRequested(),
      'stop' => const BackgroundAudioStopRequested(),
      _ => null,
    };
    if (event != null) {
      _eventsController.add(event);
    }
  }

  void _handleInterruptionEvent(AudioInterruptionEvent event) {
    if (event.type == AudioInterruptionType.duck) {
      return;
    }
    _eventsController.add(
      event.begin
          ? const BackgroundAudioInterruptionBegan()
          : const BackgroundAudioInterruptionEnded(),
    );
  }
}

class _NoopBackgroundAudioController implements BackgroundAudioController {
  const _NoopBackgroundAudioController();

  @override
  Stream<BackgroundAudioEvent> get events => const Stream.empty();

  @override
  Future<void> dispose() async {}

  @override
  Future<void> setPlaying(bool playing) async {}

  @override
  Future<void> start({required String techniqueName}) async {}

  @override
  Future<void> stop() async {}
}

abstract class RemoteControls {
  Stream<String> get commands;

  Future<void> ensureInitialized();
  Future<void> setMetadata({required String title});
  Future<void> setPlaying(bool playing);
  Future<void> shutdown();
  Future<void> dispose();
}

class _AudioServiceRemoteControls implements RemoteControls {
  static Future<AudioHandler>? _handlerFuture;

  static Future<AudioHandler> _initHandler() {
    return _handlerFuture ??= AudioService.init(
      builder: _SessionAudioHandler.new,
      config: AudioServiceConfig(
        androidNotificationChannelId:
            'life.clearbreath.clearbreath.channel.session',
        androidNotificationChannelName: 'Breathing session',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: false,
      ),
    );
  }

  AudioHandler? _handler;
  StreamSubscription<dynamic>? _sub;
  final StreamController<String> _commandsController =
      StreamController.broadcast();

  @override
  Stream<String> get commands => _commandsController.stream;

  @override
  Future<void> ensureInitialized() async {
    if (_handler != null) {
      return;
    }
    final handler = await _initHandler();
    _handler = handler;
    _sub = handler.customEvent.listen((event) {
      if (event is String) {
        _commandsController.add(event);
      }
    });
  }

  @override
  Future<void> setMetadata({required String title}) async {
    await ensureInitialized();
    await _handler!.customAction('setMetadata', {'title': title});
  }

  @override
  Future<void> setPlaying(bool playing) async {
    await ensureInitialized();
    await _handler!.customAction('setPlaying', {'playing': playing});
  }

  @override
  Future<void> shutdown() async {
    final handler = _handler;
    if (handler == null) {
      return;
    }
    await handler.customAction('shutdown');
  }

  @override
  Future<void> dispose() async {
    await _sub?.cancel();
    await _commandsController.close();
  }
}

class _SessionAudioHandler extends BaseAudioHandler {
  void _updatePlaying(bool playing) {
    final controls = playing
        ? [MediaControl.pause, MediaControl.stop]
        : [MediaControl.play, MediaControl.stop];

    playbackState.add(
      playbackState.value.copyWith(
        controls: controls,
        androidCompactActionIndices: const [0, 1],
        processingState: AudioProcessingState.ready,
        playing: playing,
      ),
    );
  }

  void _shutdown() {
    playbackState.add(
      playbackState.value.copyWith(
        controls: const [],
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
    mediaItem.add(null);
  }

  @override
  Future<void> play() async {
    customEvent.add('play');
    _updatePlaying(true);
  }

  @override
  Future<void> pause() async {
    customEvent.add('pause');
    _updatePlaying(false);
  }

  @override
  Future<void> stop() async {
    customEvent.add('stop');
    _updatePlaying(false);
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    if (name == 'setMetadata') {
      final title = extras?['title'] as String? ?? 'Session';
      mediaItem.add(
        MediaItem(id: 'session', album: 'ClearBreath', title: title),
      );
      return null;
    }

    if (name == 'setPlaying') {
      final playing = extras?['playing'] == true;
      _updatePlaying(playing);
      return null;
    }

    if (name == 'shutdown') {
      _shutdown();
      return null;
    }

    return null;
  }
}
