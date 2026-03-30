import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/shared/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state.freezed.dart';

enum AuthStatus {
  checking,
  authenticated,
  notAuthenticated,
}

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    String? token,
    @Default(AuthStatus.checking) AuthStatus status,
    AuthResponse? authResponse,
    ProfileModel? profile,
  }) = _AuthState;
}
