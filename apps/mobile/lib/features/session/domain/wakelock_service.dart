import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../shared/providers/preferences_provider.dart';

typedef WakelockCallback = Future<void> Function();

class WakelockService {
  WakelockService({
    required bool Function() isEnabled,
    required WakelockCallback enablePlatform,
    required WakelockCallback disablePlatform,
  }) : _isEnabled = isEnabled,
       _enablePlatform = enablePlatform,
       _disablePlatform = disablePlatform;

  final bool Function() _isEnabled;
  final WakelockCallback _enablePlatform;
  final WakelockCallback _disablePlatform;

  Future<void> enable() async {
    if (!_isEnabled()) {
      return;
    }
    try {
      await _enablePlatform();
    } catch (_) {}
  }

  Future<void> disable() async {
    try {
      await _disablePlatform();
    } catch (_) {}
  }
}

final wakelockServiceProvider = Provider<WakelockService>((ref) {
  return WakelockService(
    isEnabled: () => ref.read(keepScreenAwakeEnabledProvider),
    enablePlatform: () => WakelockPlus.enable(),
    disablePlatform: () => WakelockPlus.disable(),
  );
});

