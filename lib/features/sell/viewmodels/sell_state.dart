import 'package:oftal_web/shared/models/shared_models.dart';

class SellState {
  final bool isLoading;
  final String errorMessage;
  final List<PatientModel> patients;
  SellState({
    this.isLoading = false,
    this.errorMessage = '',
    this.patients = const [],
  });

  SellState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<PatientModel>? patients,
  }) {
    return SellState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      patients: patients ?? this.patients,
    );
  }
}
