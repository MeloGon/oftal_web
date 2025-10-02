import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/login/viewmodels/login_state.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:oftal_web/shared/providers/providers.dart';

part 'login_provider.g.dart';

@riverpod
class Login extends _$Login {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  LoginState build() {
    return LoginState(formKey: GlobalKey<ShadFormState>());
  }

  bool _validateForm() {
    if (state.formKey?.currentState?.validate() ?? false) {
      return true;
    }
    return false;
  }

  Future<bool> onFormSubmit() async {
    state = state.copyWith(isLoading: true);
    if (_validateForm()) {
      debugPrint('form is valid');
      try {
        await ref
            .watch(authProvider.notifier)
            .login(emailController.text, passwordController.text);
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Login realizado correctamente',
          snackbarConfig: SnackbarConfigModel(
            title: 'Aviso',
            type: SnackbarEnum.success,
          ),
        );
        return true;
      } on AuthApiException catch (e) {
        state = state.copyWith(
          errorMessage: e.message,
          isLoading: false,
          snackbarConfig: SnackbarConfigModel(
            title: 'Error',
            type: SnackbarEnum.error,
          ),
        );
        return false;
      } catch (e) {
        state = state.copyWith(
          errorMessage: 'Error al iniciar sesión',
          isLoading: false,
          snackbarConfig: SnackbarConfigModel(
            title: 'Error',
            type: SnackbarEnum.error,
          ),
        );
        return false;
      }
    }
    return false;
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void clearErrorMessage() {
    state = state.copyWith(
      errorMessage: '',
      snackbarConfig: null,
    );
  }
}
