import 'package:flutter/material.dart';
import 'package:oftal_web/shared/providers/auth_general/auth_state.dart';
import 'package:oftal_web/shared/services/local_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    Future.microtask(() {
      isAuthenticated();
    });
    return AuthState();
  }

  //tiene que consumirse el isAuthenticated apenas se construya este provider

  void login(String email, String password) {
    state = state.copyWith(token: 'asdasdasdkmom8e39jde8239ue3re');
    LocalStorage.saveToken(state.token ?? '');
    debugPrint('almacenando token ${state.token}');
    isAuthenticated();
  }

  Future<bool> isAuthenticated() async {
    final token = LocalStorage.prefs.getString('token');
    if (token == null) {
      state = state.copyWith(status: AuthStatus.notAuthenticated);
      return false;
    }
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(status: AuthStatus.authenticated);
    return true;
  }
}
