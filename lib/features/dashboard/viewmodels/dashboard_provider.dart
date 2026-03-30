import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/features/dashboard/viewmodels/dashboard_state.dart';
import 'package:oftal_web/shared/services/local_storage.dart' as local_storage;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@riverpod
class DashboardProvider extends _$DashboardProvider {
  @override
  DashboardState build() {
    Future.microtask(() {
      getSalesToday();
      getClientsByBranch();
    });
    return const DashboardState();
  }

  Future<void> getSalesToday() async {
    final profile = await local_storage.LocalStorage.getProfile();
    state = state.copyWith(isLoading: true);
    final result = await ref
        .read(saleRepositoryProvider)
        .countSalesToday(authorName: profile.name ?? '');
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        isLoading: false,
      ),
      (count) => state = state.copyWith(
        salesToday: count,
        isLoading: false,
      ),
    );
  }

  Future<void> getClientsByBranch() async {
    final profile = await local_storage.LocalStorage.getProfile();
    state = state.copyWith(isLoading: true);
    final result = await ref
        .read(saleRepositoryProvider)
        .countPatientsByBranch(branch: profile.branchName ?? '');
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        isLoading: false,
      ),
      (count) => state = state.copyWith(
        clientsByBranch: count,
        branchName: profile.branchName ?? '',
        isLoading: false,
      ),
    );
  }
}
