import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/settings/viewmodels/payments_report_provider.dart';
import 'package:oftal_web/features/settings/views/payments_report/widgets/expenses_section.dart';
import 'package:oftal_web/features/settings/views/payments_report/widgets/payments_summary_row.dart';
import 'package:oftal_web/features/settings/views/payments_report/widgets/payments_table.dart';
import 'package:oftal_web/features/settings/views/payments_report/widgets/period_filter_bar.dart';
import 'package:oftal_web/features/settings/views/payments_report/widgets/section_labels.dart';
import 'package:oftal_web/shared/models/daily_payment_model.dart';
import 'package:oftal_web/shared/models/expense_model.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PaymentsReportView extends ConsumerWidget {
  const PaymentsReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentsReportProvider);
    final notifier = ref.read(paymentsReportProvider.notifier);

    ref.listen(paymentsReportProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(notifier.clearErrorMessage);
      }
    });

    final allPayments = state.payments;
    final expenses = state.expenses;
    final filteredPayments =
        state.selectedSucursal == null
            ? allPayments
            : allPayments
                .where((p) => p.sucursal == state.selectedSucursal)
                .toList();
    final filteredExpenses =
        state.selectedSucursal == null
            ? expenses
            : expenses
                .where((e) => e.sucursal == state.selectedSucursal)
                .toList();
    final availableSucursales =
        allPayments.map((p) => p.sucursal).whereType<String>().toSet().toList()
          ..sort();
    final newSales = filteredPayments.where((p) => p.isNewSale).toList();
    final balancePayments =
        filteredPayments.where((p) => !p.isNewSale).toList();
    final totalNewSales = newSales.fold(0.0, (sum, p) => sum + p.monto);
    final totalBalancePayments = balancePayments.fold(
      0.0,
      (sum, p) => sum + p.monto,
    );
    final totalExpenses = filteredExpenses.fold(0.0, (sum, e) => sum + e.monto);
    final byMethodNewSales = _groupByMethod(newSales);
    final byMethodBalancePayments = _groupByMethod(balancePayments);
    final expensesByCategory = _groupExpensesByCategory(filteredExpenses);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          // --- Header -------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.zinc200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      'Reportes \u00b7 Ingresos y Egresos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc900,
                      ),
                    ),
                    Text(
                      'Ingresos y egresos registrados según el período seleccionado',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.zinc500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // --- Filter tabs --------------------------------------------
          PeriodFilterBar(
            state: state,
            notifier: notifier,
            availableSucursales: availableSucursales,
          ),

          // --- Summary + tables ---------------------------------------
          Expanded(
            child: SingleChildScrollView(
              child: LoadingOverlay(
                isLoading: state.isLoading,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    // -- Ingresos -----------------------------------
                    SectionLabel(
                      label: 'Ingresos',
                      total: totalNewSales + totalBalancePayments,
                      color: AppColors.sky,
                      icon: Icons.trending_up_rounded,
                    ),

                    // -- Ingresos por nuevas ventas -----------------
                    SubSectionLabel(
                      label: 'Ingresos por nuevas ventas',
                      total: totalNewSales,
                      color: AppColors.success,
                    ),
                    PaymentsSummaryRow(
                      total: totalNewSales,
                      byMethod: byMethodNewSales,
                    ),
                    ShadCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                            child: Text(
                              'Detalle de nuevas ventas (${newSales.length})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.zinc900,
                              ),
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.zinc100),
                          newSales.isEmpty
                              ? const EmptyState(
                                label:
                                    'Sin nuevas ventas en el período seleccionado',
                              )
                              : PaymentsTable(payments: newSales),
                        ],
                      ),
                    ),

                    // -- Ingresos por saldos pagados ----------------
                    SubSectionLabel(
                      label: 'Ingresos por saldos pagados',
                      total: totalBalancePayments,
                      color: AppColors.transferencia,
                    ),
                    PaymentsSummaryRow(
                      total: totalBalancePayments,
                      byMethod: byMethodBalancePayments,
                    ),
                    ShadCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                            child: Text(
                              'Detalle de saldos pagados (${balancePayments.length})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.zinc900,
                              ),
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.zinc100),
                          balancePayments.isEmpty
                              ? const EmptyState(
                                label:
                                    'Sin saldos pagados en el período seleccionado',
                              )
                              : PaymentsTable(payments: balancePayments),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // -- Egresos ------------------------------------
                    SectionLabel(
                      label: 'Egresos',
                      total: totalExpenses,
                      color: AppColors.error,
                      icon: Icons.trending_down_rounded,
                    ),
                    ExpensesSummaryRow(
                      total: totalExpenses,
                      byCategory: expensesByCategory,
                    ),
                    ShadCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                            child: Text(
                              'Detalle de egresos (${filteredExpenses.length})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.zinc900,
                              ),
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.zinc100),
                          filteredExpenses.isEmpty
                              ? const EmptyState(
                                label: 'Sin egresos en el período seleccionado',
                              )
                              : ExpensesTable(expenses: filteredExpenses),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _groupByMethod(List<DailyPaymentModel> payments) {
    final map = <String, double>{};
    for (final p in payments) {
      final key = p.metodoPago ?? 'otro';
      map[key] = (map[key] ?? 0) + p.monto;
    }
    return map;
  }

  Map<String, double> _groupExpensesByCategory(List<ExpenseModel> expenses) {
    final map = <String, double>{};
    for (final e in expenses) {
      final key = e.categoriaNombre ?? 'Sin categoría';
      map[key] = (map[key] ?? 0) + e.monto;
    }
    return map;
  }
}

void _showSnackbar(
  BuildContext context,
  SnackbarConfigModel? snackbarConfig,
  String errorMessage,
) {
  CustomSnackbar().show(
    context,
    snackbarConfig ??
        SnackbarConfigModel(title: 'Error', type: SnackbarEnum.error),
    errorMessage,
  );
}
