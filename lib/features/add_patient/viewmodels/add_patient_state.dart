import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddPatientState {
  final bool isLoading;
  final String errorMessage;
  final String? selectedGender;
  final String? selectedBranch;
  final List<PatientModel> lastPatients;
  final GlobalKey<ShadFormState>? formKey;
  final SnackbarConfigModel? snackbarConfig;

  AddPatientState({
    this.isLoading = false,
    this.errorMessage = '',
    this.selectedGender,
    this.selectedBranch,
    this.lastPatients = const [],
    this.formKey,
    this.snackbarConfig,
  });

  AddPatientState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? selectedGender,
    String? selectedBranch,
    List<PatientModel>? lastPatients,
    GlobalKey<ShadFormState>? formKey,
    SnackbarConfigModel? snackbarConfig,
  }) {
    return AddPatientState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      lastPatients: lastPatients ?? this.lastPatients,
      formKey: formKey ?? this.formKey,
      snackbarConfig: snackbarConfig ?? this.snackbarConfig,
    );
  }
}
