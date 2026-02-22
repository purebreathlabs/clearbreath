import 'package:clearbreath/features/session/domain/wakelock_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('enable calls platform when enabled', () async {
    var enabled = true;
    var enableCalls = 0;
    var disableCalls = 0;

    final service = WakelockService(
      isEnabled: () => enabled,
      enablePlatform: () async => enableCalls += 1,
      disablePlatform: () async => disableCalls += 1,
    );

    await service.enable();
    expect(enableCalls, 1);
    expect(disableCalls, 0);

    enabled = false;
    await service.enable();
    expect(enableCalls, 1);
  });

  test('disable always calls platform', () async {
    var disableCalls = 0;

    final service = WakelockService(
      isEnabled: () => false,
      enablePlatform: () async {},
      disablePlatform: () async => disableCalls += 1,
    );

    await service.disable();
    expect(disableCalls, 1);
  });
}

