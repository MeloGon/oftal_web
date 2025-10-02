import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

class LoginState {
  final bool isLoading;
  final String errorMessage;
  final bool isFormValid;
  final GlobalKey<ShadFormState>? formKey;
  final bool isPasswordVisible;
  final SnackbarConfigModel? snackbarConfig;

  LoginState({
    this.isLoading = false,
    this.errorMessage = '',
    this.isFormValid = false,
    this.formKey,
    this.isPasswordVisible = true,
    this.snackbarConfig,
  });

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isFormValid,
    GlobalKey<ShadFormState>? formKey,
    bool? isPasswordVisible,
    SnackbarConfigModel? snackbarConfig,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isFormValid: isFormValid ?? this.isFormValid,
      formKey: formKey ?? this.formKey,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      snackbarConfig: snackbarConfig ?? this.snackbarConfig,
    );
  }
}
