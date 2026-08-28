import 'package:oftal_web/shared/models/profile_model.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';

class UsersManagementState {
  final bool isLoading;
  final List<ProfileModel> users;
  final String errorMessage;
  final SnackbarConfigModel? snackbarConfig;

  const UsersManagementState({
    this.isLoading = false,
    this.users = const [],
    this.errorMessage = '',
    this.snackbarConfig,
  });

  UsersManagementState copyWith({
    bool? isLoading,
    List<ProfileModel>? users,
    String? errorMessage,
    SnackbarConfigModel? snackbarConfig,
  }) {
    return UsersManagementState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
      snackbarConfig: snackbarConfig ?? this.snackbarConfig,
    );
  }
}
