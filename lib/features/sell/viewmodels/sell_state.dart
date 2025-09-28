import 'package:oftal_web/shared/models/shared_models.dart';

class SellState {
  final bool isLoading;
  final String errorMessage;
  final List<PatientModel> patients;
  final PatientModel? selectedPatient;
  final List<ReviewModel> reviews;
  SellState({
    this.isLoading = false,
    this.errorMessage = '',
    this.patients = const [],
    this.selectedPatient,
    this.reviews = const [],
  });

  SellState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<PatientModel>? patients,
    PatientModel? selectedPatient,
    List<ReviewModel>? reviews,
  }) {
    return SellState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      patients: patients ?? this.patients,
      selectedPatient: selectedPatient ?? this.selectedPatient,
      reviews: reviews ?? this.reviews,
    );
  }
}
