import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

part 'add_patient_state.freezed.dart';

@freezed
abstract class AddPatientState with _$AddPatientState {
  const factory AddPatientState({
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
    String? selectedGender,
    String? selectedBranch,
    @Default([]) List<PatientModel> lastPatients,
    SnackbarConfigModel? snackbarConfig,
  }) = _AddPatientState;
}
