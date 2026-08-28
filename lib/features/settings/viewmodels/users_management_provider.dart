import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/viewmodels/users_management_state.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'users_management_provider.g.dart';

@riverpod
class UsersManagement extends _$UsersManagement {
  @override
  UsersManagementState build() {
    Future.microtask(loadUsers);
    return const UsersManagementState();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true);
    final result = await ref.read(userAdminRepositoryProvider).listUsers();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (users) => state = state.copyWith(isLoading: false, users: users),
    );
  }

  Future<bool> resetPassword({
    required String userId,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await ref
        .read(userAdminRepositoryProvider)
        .resetPassword(userId: userId, newPassword: newPassword);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          snackbarConfig: SnackbarConfigModel(
            title: 'Error',
            type: SnackbarEnum.error,
          ),
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Contraseña actualizada correctamente.',
          snackbarConfig: SnackbarConfigModel(
            title: 'Éxito',
            type: SnackbarEnum.success,
          ),
        );
        return true;
      },
    );
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: '', snackbarConfig: null);
  }
}
