import 'package:oftal_web/shared/models/shared_models.dart';

class SellState {
  final bool isLoading;
  final String errorMessage;
  final bool isFormValid;
  final List<PatientModel> patients;
  SellState({
    this.isLoading = false,
    this.errorMessage = '',
    this.isFormValid = false,
    this.patients = const [],
  });

  SellState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isFormValid,
    List<PatientModel>? patients,
  }) {
    return SellState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isFormValid: isFormValid ?? this.isFormValid,
      patients: patients ?? this.patients,
    );
  }
}
