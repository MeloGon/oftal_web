import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/shared/providers/auth_general/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void checkAuth() {
    state = state.copyWith(status: AuthStatus.notAuthenticated);
  }
}
