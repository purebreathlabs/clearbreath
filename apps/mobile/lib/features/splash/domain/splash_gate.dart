import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashGateProvider = Provider<SplashGate>((ref) {
  final gate = SplashGate();
  ref.onDispose(gate.dispose);
  return gate;
});

class SplashGate extends ChangeNotifier {
  bool _completed = false;

  bool get completed => _completed;

  void complete() {
    if (_completed) {
      return;
    }

    _completed = true;
    notifyListeners();
  }
}
