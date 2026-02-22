import 'package:clearbreath/features/session/domain/haptic_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('phaseTransition vibrates when enabled', () async {
    final calls = <int>[];
    final service = HapticService(
      isEnabled: () => true,
      vibrate: (durationMs) async => calls.add(durationMs),
    );

    await service.phaseTransition();
    expect(calls, [40]);
  });

  test('phaseTransition does nothing when disabled', () async {
    final calls = <int>[];
    final service = HapticService(
      isEnabled: () => false,
      vibrate: (durationMs) async => calls.add(durationMs),
    );

    await service.phaseTransition();
    expect(calls, isEmpty);
  });

  test('tick vibrates when enabled', () async {
    final calls = <int>[];
    final service = HapticService(
      isEnabled: () => true,
      vibrate: (durationMs) async => calls.add(durationMs),
    );

    await service.tick();
    expect(calls, [20]);
  });

  test('sessionComplete vibrates when enabled', () async {
    final calls = <int>[];
    final service = HapticService(
      isEnabled: () => true,
      vibrate: (durationMs) async => calls.add(durationMs),
    );

    await service.sessionComplete();
    expect(calls, [100]);
  });
}

