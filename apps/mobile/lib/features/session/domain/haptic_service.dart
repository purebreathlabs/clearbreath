import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../../shared/providers/preferences_provider.dart';

typedef VibrateCallback = Future<void> Function(int durationMs);

class HapticService {
  HapticService({
    required bool Function() isEnabled,
    required VibrateCallback vibrate,
  }) : _isEnabled = isEnabled,
       _vibrate = vibrate;

  final bool Function() _isEnabled;
  final VibrateCallback _vibrate;

  Future<void> phaseTransition() async {
    if (!_isEnabled()) {
      return;
    }
    try {
      await _vibrate(40);
    } catch (_) {}
  }

  Future<void> sessionComplete() async {
    if (!_isEnabled()) {
      return;
    }
    try {
      await _vibrate(100);
    } catch (_) {}
  }

  Future<void> tick() async {
    if (!_isEnabled()) {
      return;
    }
    try {
      await _vibrate(20);
    } catch (_) {}
  }
}

final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService(
    isEnabled: () => ref.read(hapticsEnabledProvider),
    vibrate: (durationMs) => Vibration.vibrate(duration: durationMs),
  );
});

