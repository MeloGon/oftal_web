import 'package:oftal_web/features/settings/viewmodels/settings_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  @override
  SettingsState build() {
    return SettingsState();
  }

  void clearErrorMessage() {
    state = state.copyWith(
      errorMessage: '',
      snackbarConfig: null,
    );
  }
}
