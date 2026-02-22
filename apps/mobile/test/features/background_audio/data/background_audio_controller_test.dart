import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:clearbreath/features/background_audio/data/background_audio_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('emits interruption events', () async {
    final interruptions = StreamController<AudioInterruptionEvent>.broadcast();
    addTearDown(interruptions.close);

    final remote = _FakeRemoteControls();
    addTearDown(remote.dispose);

    final controller = AudioServiceBackgroundAudioController(
      remoteControls: remote,
      interruptionEvents: interruptions.stream,
      enableAudioSession: false,
      enableSilentAudio: false,
    );
    addTearDown(controller.dispose);

    final events = <BackgroundAudioEvent>[];
    final sub = controller.events.listen(events.add);
    addTearDown(sub.cancel);

    await controller.start(techniqueName: 'Box');
    expect(
      remote.actions,
      containsAllInOrder(['metadata:Box', 'playing:true']),
    );

    interruptions.add(
      AudioInterruptionEvent(true, AudioInterruptionType.pause),
    );
    await Future<void>.delayed(Duration.zero);

    expect(events.last, isA<BackgroundAudioInterruptionBegan>());

    interruptions.add(
      AudioInterruptionEvent(false, AudioInterruptionType.pause),
    );
    await Future<void>.delayed(Duration.zero);

    expect(events.last, isA<BackgroundAudioInterruptionEnded>());
  });

  test('emits remote control events', () async {
    final remote = _FakeRemoteControls();
    addTearDown(remote.dispose);

    final controller = AudioServiceBackgroundAudioController(
      remoteControls: remote,
      enableAudioSession: false,
      enableSilentAudio: false,
    );
    addTearDown(controller.dispose);

    final events = <BackgroundAudioEvent>[];
    final sub = controller.events.listen(events.add);
    addTearDown(sub.cancel);

    await controller.start(techniqueName: 'Box');

    remote.emit('pause');
    await Future<void>.delayed(Duration.zero);
    expect(events.last, isA<BackgroundAudioPauseRequested>());

    remote.emit('play');
    await Future<void>.delayed(Duration.zero);
    expect(events.last, isA<BackgroundAudioPlayRequested>());

    remote.emit('stop');
    await Future<void>.delayed(Duration.zero);
    expect(events.last, isA<BackgroundAudioStopRequested>());
  });

  test('remote controls still emit after stop and restart', () async {
    final remote = _FakeRemoteControls();
    addTearDown(remote.dispose);

    final controller = AudioServiceBackgroundAudioController(
      remoteControls: remote,
      enableAudioSession: false,
      enableSilentAudio: false,
    );
    addTearDown(controller.dispose);

    final events = <BackgroundAudioEvent>[];
    final sub = controller.events.listen(events.add);
    addTearDown(sub.cancel);

    await controller.start(techniqueName: 'Box');
    await controller.stop();
    await controller.start(techniqueName: 'Box');

    remote.emit('pause');
    await Future<void>.delayed(Duration.zero);

    expect(events.last, isA<BackgroundAudioPauseRequested>());
  });
}

class _FakeRemoteControls implements RemoteControls {
  final StreamController<String> _commands = StreamController.broadcast();
  final List<String> actions = [];

  @override
  Stream<String> get commands => _commands.stream;

  void emit(String command) => _commands.add(command);

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<void> setMetadata({required String title}) async {
    actions.add('metadata:$title');
  }

  @override
  Future<void> setPlaying(bool playing) async {
    actions.add('playing:$playing');
  }

  @override
  Future<void> shutdown() async {
    actions.add('shutdown');
  }

  @override
  Future<void> dispose() async {
    await _commands.close();
  }
}
