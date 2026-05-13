import 'package:intl/intl.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/viewmodels/payments_report_state.dart';
import 'package:oftal_web/shared/models/expense_model.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payments_report_provider.g.dart';

@riverpod
class PaymentsReport extends _$PaymentsReport {
  static final _fmt = DateFormat('yyyy-MM-dd');

  @override
  PaymentsReportState build() {
    final now = DateTime.now();
    Future.microtask(loadPayments);
    return PaymentsReportState(
      selectedDay: now,
      selectedMonth: DateTime(now.year, now.month),
      rangeStart: now,
      rangeEnd: now,
    );
  }

  Future<void> loadPayments() async {
    state = state.copyWith(isLoading: true, payments: [], expenses: []);
    final (from, to) = _currentRange();

    final paymentsResult = await ref
        .read(paymentRepositoryProvider)
        .getPaymentsByDateRange(from, to);
    final expensesResult = await ref
        .read(expenseRepositoryProvider)
        .getExpensesByDateRange(from, to);

    List<ExpenseModel> expenses = [];
    expensesResult.fold((_) {}, (list) => expenses = list);

    paymentsResult.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (payments) => state = state.copyWith(
        isLoading: false,
        payments: payments,
        expenses: expenses,
      ),
    );
  }

  void selectFilter(ReportPeriodFilter filter) {
    state = state.copyWith(filter: filter);
    loadPayments();
  }

  void selectDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
    loadPayments();
  }

  void selectMonth(DateTime month) {
    state = state.copyWith(selectedMonth: DateTime(month.year, month.month));
    loadPayments();
  }

  void selectRangeStart(DateTime date) {
    final end = date.isAfter(state.rangeEnd) ? date : state.rangeEnd;
    state = state.copyWith(rangeStart: date, rangeEnd: end);
    loadPayments();
  }

  void selectRangeEnd(DateTime date) {
    final start = date.isBefore(state.rangeStart) ? date : state.rangeStart;
    state = state.copyWith(rangeStart: start, rangeEnd: date);
    loadPayments();
  }

  void selectSucursal(String? sucursal) {
    state = state.copyWith(selectedSucursal: sucursal);
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: '', snackbarConfig: null);
  }

  (String from, String to) _currentRange() {
    return switch (state.filter) {
      ReportPeriodFilter.day => (
          _fmt.format(state.selectedDay),
          _fmt.format(state.selectedDay),
        ),
      ReportPeriodFilter.month => (
          _fmt.format(DateTime(state.selectedMonth.year, state.selectedMonth.month, 1)),
          _fmt.format(DateTime(state.selectedMonth.year, state.selectedMonth.month + 1, 0)),
        ),
      ReportPeriodFilter.range => (
          _fmt.format(state.rangeStart),
          _fmt.format(state.rangeEnd),
        ),
    };
  }
}
