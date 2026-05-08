import 'package:intl/intl.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/features/dashboard/viewmodels/dashboard_state.dart';
import 'package:oftal_web/shared/services/local_storage.dart' as local_storage;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@riverpod
class DashboardProvider extends _$DashboardProvider {
  static final _fmt = DateFormat('yyyy-MM-dd');

  @override
  DashboardState build() {
    Future.microtask(_loadAll);
    return const DashboardState();
  }

  Future<void> _loadAll() async {
    final profile = await local_storage.LocalStorage.getProfile();
    final name = profile.name ?? '';
    final branch = profile.branchName ?? '';

    state = state.copyWith(userName: name, branchName: branch);

    await Future.wait([
      _fetchSalesToday(name),
      _fetchClientsByBranch(branch),
      _fetchIncomeAndPayments(),
      _fetchRecentSales(),
      _fetchSalesByDay(branch),
    ]);
  }

  Future<void> _fetchSalesToday(String authorName) async {
    final result = await ref
        .read(saleRepositoryProvider)
        .countSalesToday(authorName: authorName);
    result.fold(
      (f) => state = state.copyWith(errorMessage: f.message),
      (count) => state = state.copyWith(salesToday: count),
    );
  }

  Future<void> _fetchClientsByBranch(String branch) async {
    final result = await ref
        .read(saleRepositoryProvider)
        .countPatientsByBranch(branch: branch);
    result.fold(
      (f) => state = state.copyWith(errorMessage: f.message),
      (count) => state = state.copyWith(clientsByBranch: count),
    );
  }

  Future<void> _fetchIncomeAndPayments() async {
    final today = _fmt.format(DateTime.now());
    final result = await ref
        .read(paymentRepositoryProvider)
        .getPaymentsByDateRange(today, today);
    result.fold(
      (_) => null,
      (payments) {
        final income = payments.fold(0.0, (s, p) => s + p.monto);
        final methods = <String, double>{};
        for (final p in payments) {
          final m = p.metodoPago ?? 'otro';
          methods[m] = (methods[m] ?? 0) + p.monto;
        }
        state = state.copyWith(incomeToday: income, paymentsByMethod: methods);
      },
    );
  }

  Future<void> _fetchRecentSales() async {
    final result = await ref
        .read(saleRepositoryProvider)
        .getRecentSales(limit: 5);
    result.fold(
      (_) => null,
      (sales) => state = state.copyWith(recentSales: sales),
    );
  }

  Future<void> _fetchSalesByDay(String branch) async {
    final now = DateTime.now();
    final from = _fmt.format(now.subtract(const Duration(days: 6)));
    final to = _fmt.format(now);
    final result = await ref
        .read(saleRepositoryProvider)
        .getSalesDatesInRange(branch: branch, from: from, to: to);
    result.fold(
      (_) => null,
      (dates) {
        final counts = <String, int>{};
        for (int i = 6; i >= 0; i--) {
          counts[_fmt.format(now.subtract(Duration(days: i)))] = 0;
        }
        for (final d in dates) {
          if (counts.containsKey(d)) counts[d] = counts[d]! + 1;
        }
        state = state.copyWith(salesByDay: counts);
      },
    );
  }

  // Called by external refresh button if needed
  Future<void> refresh() => _loadAll();
}
