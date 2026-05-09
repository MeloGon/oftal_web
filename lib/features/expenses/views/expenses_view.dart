import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/datatables/datatables.dart';
import 'package:oftal_web/features/expenses/viewmodels/expenses_provider.dart';
import 'package:oftal_web/features/expenses/views/widgets/expense_category_dialog.dart';
import 'package:oftal_web/features/expenses/views/widgets/expense_form_dialog.dart';
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
  late ExpensesDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(expensesProvider).expenses;
    _dataSource = ExpensesDataSource(
      expenses: initial,
      context: context,
      onEdit: _handleEdit,
      onDelete: _handleDelete,
    );
  }

  void _handleEdit(ExpenseModel expense) {
    ExpenseFormDialog().show(context, ref, expense: expense);
  }

  void _handleDelete(ExpenseModel expense) {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expensesProvider);
    final notifier = ref.read(expensesProvider.notifier);
    _dataSource.update(state.expenses, context);

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
              const Expanded(child: _PageHeader()),
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

          // ─── Summary cards ────────────────────────────────────
          Row(
            spacing: 12,
            children: [
              _SummaryCard(
                label: 'Total egresos',
                value: total.toCurrency(),
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xffEF4444),
                iconBg: const Color(0xffFEE2E2),
              ),
              _SummaryCard(
                label: 'Registros',
                value: '${state.expenses.length}',
                icon: Icons.receipt_long_outlined,
                iconColor: const Color(0xff6366F1),
                iconBg: const Color(0xffEEECFE),
              ),
              _SummaryCard(
                label: 'Categorías',
                value: '${state.categories.length}',
                icon: Icons.label_outline,
                iconColor: const Color(0xff10B981),
                iconBg: const Color(0xffD1FAE5),
              ),
            ],
          ),

          // ─── Table ────────────────────────────────────────────
          Expanded(
            child: ShadCard(
              padding: EdgeInsets.zero,
              child: TooltipVisibility(
                visible: false,
                child: PaginatedDataTable2(
                  headingRowHeight: 40,
                  showCheckboxColumn: false,
                  wrapInCard: false,
                  fixedLeftColumns: 1,
                  columnSpacing: 12,
                  horizontalMargin: 16,
                  minWidth: 1100,
                  isHorizontalScrollBarVisible: true,
                  isVerticalScrollBarVisible: true,
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xffFAFAFA),
                  ),
                  source: _dataSource,
                  availableRowsPerPage: const [20],
                  rowsPerPage: state.rowsPerPage,
                  onRowsPerPageChanged:
                      (v) => notifier.changeRowsPerPage(v ?? 20),
                  columns: const [
                    DataColumn2(
                      label: SizedBox.shrink(),
                      fixedWidth: 48,
                      isResizable: false,
                    ),
                    DataColumn2(
                      label: _ColHeader('Categoría'),
                      fixedWidth: 160,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('Fecha'),
                      fixedWidth: 100,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('Descripción'),
                      size: ColumnSize.L,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('Método pago'),
                      fixedWidth: 120,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('Comprobante'),
                      fixedWidth: 120,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('Sucursal'),
                      fixedWidth: 100,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('Registrado por'),
                      fixedWidth: 130,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('Monto'),
                      fixedWidth: 100,
                      isResizable: true,
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
}

// ─── Local widgets ────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        const Text(
          'Egresos',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xff18181B),
          ),
        ),
        Text(
          'Registra y consulta todos los gastos',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

class _ColHeader extends StatelessWidget {
  const _ColHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xff52525B),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 12,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xff18181B),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
