import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

part 'mounts_state.freezed.dart';

@freezed
abstract class MountsState with _$MountsState {
  const factory MountsState({
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
    @Default([]) List<MountModel> mounts,
    @Default(10) int rowsPerPage,
    @Default(0) int totalCount,
    @Default(0) int offset,
    @Default(true) bool hasMore,
    SnackbarConfigModel? snackbarConfig,
    @Default(false) bool isAddMountDialogOpen,
    @Default(false) bool isSearchMode,
    MountModel? selectedMount,
  }) = _MountsState;
}
