import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
    SnackbarConfigModel? snackbarConfig,
  }) = _SettingsState;
}
