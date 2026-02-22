import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';
import 'auth_state.dart';

final authStateProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
