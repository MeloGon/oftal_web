import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';

part 'login_state.freezed.dart';

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
    @Default(false) bool isFormValid,
    @Default(true) bool isPasswordVisible,
    SnackbarConfigModel? snackbarConfig,
  }) = _LoginState;
}
