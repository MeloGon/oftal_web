import 'package:intl/intl.dart';
import 'package:oftal_web/features/dashboard/viewmodels/dashboard_state.dart';
import 'package:oftal_web/shared/services/local_storage.dart' as local_storage;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'dashboard_provider.g.dart';

@riverpod
class DashboardProvider extends _$DashboardProvider {
  @override
  DashboardState build() {
    Future.microtask(() {
      getSalesToday();
      getClientsByBranch();
    });
    return DashboardState();
  }

  Future<void> getSalesToday() async {
    final profile = await local_storage.LocalStorage.getProfile();
    state = state.copyWith(isLoading: true);
    try {
      final response =
          await Supabase.instance.client
              .from('ventas cortas')
              .select(
                '*',
              )
              .eq('"AUTOR NOMBRE"', profile.name ?? '')
              .eq(
                '"fecha_actualizada"',
                DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
              )
              .count();

      final totalPagadas = response.count;
      state = state.copyWith(salesToday: totalPagadas);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> getClientsByBranch() async {
    final profile = await local_storage.LocalStorage.getProfile();
    state = state.copyWith(isLoading: true);
    try {
      final response =
          await Supabase.instance.client
              .from('pacientes')
              .select('*')
              .eq('"SUCURSAL"', profile.branchName ?? '')
              .count();
      final clientesByBranch = response.count;
      state = state.copyWith(
        clientsByBranch: clientesByBranch,
        branchName: profile.branchName ?? '',
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
