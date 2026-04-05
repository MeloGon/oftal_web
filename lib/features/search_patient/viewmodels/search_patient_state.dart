import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

part 'search_patient_state.freezed.dart';

@freezed
abstract class SearchPatientState with _$SearchPatientState {
  const factory SearchPatientState({
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
    @Default([]) List<PatientModel> patients,
    SnackbarConfigModel? snackbarConfig,
    @Default([]) List<ReviewModel> reviews,
    @Default(false) bool isAddViewMeasureDialogOpen,
    @Default(false) bool isReviewDialogOpen,
    @Default(false) bool isEditDialogOpen,
    PatientModel? patientToEdit,
    @Default(10) int rowsPerPage,
    @Default('') String patientName,
  }) = _SearchPatientState;
}
