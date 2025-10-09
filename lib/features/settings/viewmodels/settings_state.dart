import 'package:oftal_web/shared/models/shared_models.dart';

class SettingsState {
  final bool isLoading;
  final String errorMessage;
  final SnackbarConfigModel? snackbarConfig;

  SettingsState({
    this.isLoading = false,
    this.errorMessage = '',
    this.snackbarConfig,
  });

  SettingsState copyWith({
    bool? isLoading,
    String? errorMessage,
    SnackbarConfigModel? snackbarConfig,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      snackbarConfig: snackbarConfig ?? this.snackbarConfig,
    );
  }
}
