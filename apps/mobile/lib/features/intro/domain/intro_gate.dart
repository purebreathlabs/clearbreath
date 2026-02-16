import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final introGateProvider = Provider<IntroGate>((ref) {
  final gate = IntroGate();
  ref.onDispose(gate.dispose);
  return gate;
});

class IntroGate extends ChangeNotifier {
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
