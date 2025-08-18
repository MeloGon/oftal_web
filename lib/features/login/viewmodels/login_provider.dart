import 'package:flutter/material.dart';
import 'package:oftal_web/features/login/viewmodels/login_state.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

part 'login_provider.g.dart';

@riverpod
class Login extends _$Login {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  LoginState build() {
    return LoginState(formKey: GlobalKey<ShadFormState>());
  }

  bool validateForm() {
    if (state.formKey?.currentState?.validate() ?? false) {
      return true;
    }

    return false;
  }

  bool onFormSubmit() {
    if (validateForm()) {
      //TODO: hacer el login
      debugPrint('form is valid');
      ref
          .watch(authProvider.notifier)
          .login(emailController.text, passwordController.text);
      return true;
    } else {
      debugPrint('form is invalid');
      return false;
    }
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }
}
