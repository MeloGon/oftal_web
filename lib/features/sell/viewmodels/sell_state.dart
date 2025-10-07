import 'package:oftal_web/shared/models/shared_models.dart';

class SellState {
  final bool isLoading;
  final String errorMessage;
  final List<PatientModel> patients;
  final PatientModel? selectedPatient;
  final PatientModel? patientToSell;
  final List<ReviewModel> reviews;
  final List<MountModel> mounts;
  SnackbarConfigModel? snackbarConfig;
  SellState({
    this.isLoading = false,
    this.errorMessage = '',
    this.patients = const [],
    this.selectedPatient,
    this.patientToSell,
    this.reviews = const [],
    this.mounts = const [],
    this.snackbarConfig,
  });

  SellState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<PatientModel>? patients,
    PatientModel? selectedPatient,
    PatientModel? patientToSell,
    List<ReviewModel>? reviews,
    List<MountModel>? mounts,
    SnackbarConfigModel? snackbarConfig,
  }) {
    return SellState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      patients: patients ?? this.patients,
      selectedPatient: selectedPatient ?? this.selectedPatient,
      patientToSell: patientToSell ?? this.patientToSell,
      reviews: reviews ?? this.reviews,
      mounts: mounts ?? this.mounts,
      snackbarConfig: snackbarConfig ?? this.snackbarConfig,
    );
  }
}
