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
    @Default(0) int offset,
    @Default(10) int pageSize,
    @Default(false) bool hasMore,
    @Default('') String patientName,
  }) = _SearchPatientState;

  const SearchPatientState._();

  int get pageNumber => (offset ~/ pageSize) + 1;
}
