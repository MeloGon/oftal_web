import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/expenses/viewmodels/expenses_provider.dart';
import 'package:oftal_web/features/expenses/views/widgets/expense_category_dialog.dart';
import 'package:oftal_web/features/expenses/views/widgets/expense_filter_bar.dart';
import 'package:oftal_web/features/expenses/views/widgets/expense_form_dialog.dart';
import 'package:oftal_web/features/expenses/views/widgets/expense_summary_cards.dart';
import 'package:oftal_web/features/expenses/views/widgets/expense_tile.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ExpensesView extends ConsumerStatefulWidget {
  const ExpensesView({super.key});

  @override
  ConsumerState<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends ConsumerState<ExpensesView> {
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(expensesProvider.notifier).setSearchQuery(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expensesProvider);
    final notifier = ref.read(expensesProvider.notifier);

    ref.listenLoading(
      expensesProvider.select((s) => s.isLoading),
      context,
    );

    ref.listen(expensesProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        CustomSnackbar().show(
          context,
          next.snackbarConfig ??
              SnackbarConfigModel(title: 'Error', type: SnackbarEnum.error),
          next.errorMessage,
        );
        Future.microtask(() => notifier.clearErrorMessage());
      }
    });

    final total = state.expenses.fold(0.0, (s, e) => s + e.monto);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // ─── Header ───────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    const Text(
                      'Egresos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc900,
                      ),
                    ),
                    Text(
                      'Registra y consulta todos los gastos',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              ShadButton.outline(
                size: ShadButtonSize.sm,
                onPressed: () => ExpenseCategoryDialog().show(context, ref),
                child: const Row(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune_outlined, size: 14),
                    Text('Categorías'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ShadButton(
                size: ShadButtonSize.sm,
                onPressed: () => ExpenseFormDialog().show(context, ref),
                child: const Row(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14),
                    Text('Nuevo egreso'),
                  ],
                ),
              ),
            ],
          ),

          // ─── Summary ──────────────────────────────────────────
          ExpenseSummaryCards(
            totalAmount: total.toCurrency(),
            recordCount: '${state.expenses.length}',
            categoryCount: '${state.categories.length}',
          ),

          // ─── Filters ──────────────────────────────────────────
          ExpenseFilterBar(
            state: state,
            onSearchChanged: _onSearchChanged,
          ),

          // ─── List ─────────────────────────────────────────────
          Expanded(
            child: ShadCard(
              padding: EdgeInsets.zero,
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.expenses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8,
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 36, color: Colors.grey.shade300),
                              Text(
                                'Sin egresos registrados',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : ExpensesList(
                          expenses: state.expenses,
                          onEdit: (e) => ExpenseFormDialog()
                              .show(context, ref, expense: e),
                          onDelete: (e) => _confirmDelete(e),
                        ),
            ),
          ),

          // ─── Pagination ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Página ${state.pageNumber}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 12),
              ShadButton.outline(
                size: ShadButtonSize.sm,
                enabled: state.offset > 0 && !state.isLoading,
                onPressed: notifier.prevPage,
                child: const Icon(Icons.chevron_left, size: 16),
              ),
              const SizedBox(width: 6),
              ShadButton.outline(
                size: ShadButtonSize.sm,
                enabled: state.hasMore && !state.isLoading,
                onPressed: notifier.nextPage,
                child: const Icon(Icons.chevron_right, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ExpenseModel expense) {
    showShadDialog(
      context: context,
      builder: (dialogCtx) => ShadDialog.alert(
        title: const Text('Eliminar egreso'),
        description: Text(
          '¿Eliminar el egreso "${expense.descripcion}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          ShadButton.destructive(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              if (expense.id != null) {
                ref
                    .read(expensesProvider.notifier)
                    .deleteExpense(expense.id!);
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
