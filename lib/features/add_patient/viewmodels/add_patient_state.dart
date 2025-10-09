import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddPatientState {
  final bool isLoading;
  final String errorMessage;
  final String? selectedGender;
  final String? selectedBranch;
  final List<PatientModel> patients;
  final PatientModel? patient;
  final GlobalKey<ShadFormState>? formKey;
  final SnackbarConfigModel? snackbarConfig;
  final bool isAddViewMeasureDialogOpen;
  final PatientModel? patientSelected;

  AddPatientState({
    this.isLoading = false,
    this.errorMessage = '',
    this.selectedGender,
    this.selectedBranch,
    this.patients = const [],
    this.patient,
    this.formKey,
    this.snackbarConfig,
    this.isAddViewMeasureDialogOpen = false,
    this.patientSelected,
  });

  AddPatientState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? selectedGender,
    String? selectedBranch,
    List<PatientModel>? patients,
    PatientModel? patient,
    GlobalKey<ShadFormState>? formKey,
    SnackbarConfigModel? snackbarConfig,
    bool? isAddViewMeasureDialogOpen,
    PatientModel? patientSelected,
  }) {
    return AddPatientState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      patients: patients ?? this.patients,
      patient: patient ?? this.patient,
      formKey: formKey ?? this.formKey,
      snackbarConfig: snackbarConfig ?? this.snackbarConfig,
      isAddViewMeasureDialogOpen:
          isAddViewMeasureDialogOpen ?? this.isAddViewMeasureDialogOpen,
      patientSelected: patientSelected ?? this.patientSelected,
    );
  }
}
