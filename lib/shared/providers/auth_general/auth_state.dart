enum AuthStatus {
  checking,
  authenticated,
  notAuthenticated,
}

class AuthState {
  final String? token;
  final AuthStatus status;

  AuthState({
    this.token,
    this.status = AuthStatus.notAuthenticated,
  });

  AuthState copyWith({
    String? token,
    AuthStatus? status,
  }) {
    return AuthState(
      token: token ?? this.token,
      status: status ?? this.status,
    );
  }
}
