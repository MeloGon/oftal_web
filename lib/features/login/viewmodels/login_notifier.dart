import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/login/viewmodels/login_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(LoginState(formKey: GlobalKey<ShadFormState>()));

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool validateForm() {
    if (state.formKey?.currentState?.validate() ?? false) {
      return true;
    }

    return false;
  }

  void onFormSubmit() {
    if (validateForm()) {
      //TODO: hacer el login
      print('form is valid');
    } else {
      print('form is invalid');
    }
  }
}
