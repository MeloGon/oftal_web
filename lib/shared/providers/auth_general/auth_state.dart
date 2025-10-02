import 'package:oftal_web/shared/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus {
  checking,
  authenticated,
  notAuthenticated,
}

class AuthState {
  final String? token;
  final AuthStatus status;
  final AuthResponse? authResponse;
  final ProfileModel? profile;

  AuthState({
    this.token,
    this.status = AuthStatus.checking,
    this.authResponse,
    this.profile,
  });

  AuthState copyWith({
    String? token,
    AuthStatus? status,
    AuthResponse? authResponse,
    ProfileModel? profile,
  }) {
    return AuthState(
      token: token ?? this.token,
      status: status ?? this.status,
      authResponse: authResponse ?? this.authResponse,
      profile: profile ?? this.profile,
    );
  }
}
