import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/profile_model.dart';
import 'package:oftal_web/shared/providers/auth_general/auth_state.dart';
import 'package:oftal_web/shared/services/local_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    Future.microtask(() {
      _isAuthenticated();
      // _getUserData();
    });
    return AuthState();
  }

  Future<void> _getUserData() async {
    debugPrint('obteniendo datos del usuario ${state.authResponse?.user?.id}');
    try {
      debugPrint(
        'obteniendo datos del usuario 2 ${state.authResponse?.user?.id}',
      );
      final response = await supabase.Supabase.instance.client
          .from('perfiles')
          .select()
          .eq('id', state.authResponse?.user?.id ?? '');
      debugPrint('datos del usuario ${response.first}');
      LocalStorage.saveProfile(ProfileModel.fromJson(response.first));
      state = state.copyWith(profile: ProfileModel.fromJson(response.first));
    } catch (e) {
      debugPrint('error al obtener datos del usuario $e');
      state = state.copyWith(profile: null);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final loginResponse = await supabase.Supabase.instance.client.auth
          .signInWithPassword(
            email: email,
            password: password,
          );

      state = state.copyWith(
        token: loginResponse.session?.accessToken,
        authResponse: loginResponse,
      );
      LocalStorage.saveToken(loginResponse.session?.accessToken ?? '');
      final userData = await LocalStorage.getProfile();
      if (userData.id == null) {
        _getUserData();
      }
      state = state.copyWith(profile: userData);
      debugPrint('almacenando token ${state.token}');
      _isAuthenticated();
    } catch (e) {
      rethrow; // Re-lanza la excepción original sin envolverla
    }
  }

  Future<bool> _isAuthenticated() async {
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
