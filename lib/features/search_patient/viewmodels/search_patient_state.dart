import 'package:oftal_web/shared/models/shared_models.dart';

class SearchPatientState {
  final bool isLoading;
  final String errorMessage;
  final List<PatientModel> patients;
  final SnackbarConfigModel? snackbarConfig;
  final List<ReviewModel> reviews;
  final bool isAddViewMeasureDialogOpen;
  final int rowsPerPage;

  SearchPatientState({
    this.isLoading = false,
    this.errorMessage = '',
    this.patients = const [],
    this.snackbarConfig,
    this.reviews = const [],
    this.isAddViewMeasureDialogOpen = false,
    this.rowsPerPage = 7,
  });

  SearchPatientState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<PatientModel>? patients,
    SnackbarConfigModel? snackbarConfig,
    List<ReviewModel>? reviews,
    bool? isAddViewMeasureDialogOpen,
    int? rowsPerPage,
  }) {
    return SearchPatientState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      patients: patients ?? this.patients,
      snackbarConfig: snackbarConfig ?? this.snackbarConfig,
      reviews: reviews ?? this.reviews,
      isAddViewMeasureDialogOpen:
          isAddViewMeasureDialogOpen ?? this.isAddViewMeasureDialogOpen,
      rowsPerPage: rowsPerPage ?? this.rowsPerPage,
    );
  }
}
