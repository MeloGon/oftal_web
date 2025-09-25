import 'package:oftal_web/shared/models/shared_models.dart';

class AddPatientState {
  final bool isLoading;
  final String errorMessage;
  final String? selectedGender;
  final String? selectedBranch;
  final List<PatientModel> patients;
  AddPatientState({
    this.isLoading = false,
    this.errorMessage = '',
    this.selectedGender,
    this.selectedBranch,
    this.patients = const [],
  });

  AddPatientState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? selectedGender,
    String? selectedBranch,
    List<PatientModel>? patients,
  }) {
    return AddPatientState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      patients: patients ?? this.patients,
    );
  }
}
