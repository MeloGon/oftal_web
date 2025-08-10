import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginState {
  final bool isLoading;
  final String errorMessage;
  final bool isFormValid;
  final GlobalKey<ShadFormState>? formKey;

  LoginState({
    this.isLoading = false,
    this.errorMessage = '',
    this.isFormValid = false,
    this.formKey,
  });

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isFormValid,
    GlobalKey<ShadFormState>? formKey,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isFormValid: isFormValid ?? this.isFormValid,
      formKey: formKey ?? this.formKey,
    );
  }
}
