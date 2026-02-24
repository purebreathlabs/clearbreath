import '../../../core/network/models/user_models.dart';

sealed class AuthState {
  const AuthState();

  bool get isGuest => this is AuthStateGuest;
  bool get isSignedIn => this is AuthStateSignedIn;
}

final class AuthStateGuest extends AuthState {
  const AuthStateGuest();
}

final class AuthStateSignedIn extends AuthState {
  const AuthStateSignedIn({required this.profile, this.sessionReady = true});

  final UserProfile profile;
  final bool sessionReady;

  String get userId => profile.id;
}
