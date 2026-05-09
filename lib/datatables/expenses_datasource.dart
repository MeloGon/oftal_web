import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class ExpensesDataSource extends DataTableSource {
  List<ExpenseModel> expenses;
  BuildContext context;
  final void Function(ExpenseModel) onEdit;
  final void Function(ExpenseModel) onDelete;

  static final _cellStyle = TextStyle(
    fontSize: 13,
    fontFamily: GoogleFonts.poppins().fontFamily,
  );

  ExpensesDataSource({
    required this.expenses,
    required this.context,
    required this.onEdit,
    required this.onDelete,
  });

  void update(List<ExpenseModel> newExpenses, BuildContext ctx) {
    context = ctx;
    if (identical(expenses, newExpenses)) return;
    expenses = newExpenses;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    final e = expenses[index];
    final s = _cellStyle;
    return DataRow.byIndex(
      onSelectChanged: (_) {},
      index: index,
      cells: [
        DataCell(_CategoryBadge(expense: e)),
        DataCell(Text(e.fecha, style: s)),
        DataCell(Text(e.descripcion, style: s)),
        DataCell(Text(_capitalize(e.metodoPago), style: s)),
        DataCell(Text(e.comprobante ?? '—', style: s)),
        DataCell(Text(e.sucursal ?? 'Global', style: s)),
        DataCell(Text(e.registradoPor ?? '—', style: s)),
        DataCell(Text(e.monto.toCurrency(), style: s)),
        DataCell(
          _ExpenseActions(
            onEdit: () => onEdit(e),
            onDelete: () => onDelete(e),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => expenses.length;

  @override
  int get selectedRowCount => 0;
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

// ─── Category badge ───────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.expense});
  final ExpenseModel expense;

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(expense.categoriaColor);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        expense.categoriaNombre ?? 'Sin categoría',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

Color _hexToColor(String? hex) {
  if (hex == null || hex.isEmpty) return const Color(0xff6366F1);
  final clean = hex.replaceFirst('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

// ─── Actions ─────────────────────────────────────────────────────────────────

class _ExpenseActions extends StatelessWidget {
  const _ExpenseActions({required this.onEdit, required this.onDelete});
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Tooltip(
          message: 'Editar',
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.edit_outlined, size: 18),
              ),
            ),
          ),
        ),
        Tooltip(
          message: 'Eliminar',
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.delete_outlined, size: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
