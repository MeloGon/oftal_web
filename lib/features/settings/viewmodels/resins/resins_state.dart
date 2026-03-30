import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

part 'resins_state.freezed.dart';

@freezed
abstract class ResinsState with _$ResinsState {
  const factory ResinsState({
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
    @Default([]) List<ResinModel> resins,
    @Default(10) int rowsPerPage,
    @Default(0) int totalCount,
    @Default(0) int offset,
    @Default(true) bool hasMore,
    SnackbarConfigModel? snackbarConfig,
    @Default(false) bool isAddResinDialogOpen,
    ResinModel? selectedResin,
  }) = _ResinsState;
}
