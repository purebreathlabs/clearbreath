import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_state.dart';

final authStateProvider = NotifierProvider<AuthStateController, AuthState>(
  AuthStateController.new,
);

class AuthStateController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthStateGuest();

  void setGuest() => state = const AuthStateGuest();

  void setSignedIn(String userId) {
    state = AuthStateSignedIn(userId: userId);
  }
}
