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
        DataCell(
          _ExpenseActions(
            onEdit: () => onEdit(e),
            onDelete: () => onDelete(e),
          ),
        ),
        DataCell(_CategoryBadge(expense: e)),
        DataCell(Text(e.fecha, style: s)),
        DataCell(Text(e.descripcion, style: s)),
        DataCell(Text(_capitalize(e.metodoPago), style: s)),
        DataCell(Text(e.comprobante ?? '—', style: s)),
        DataCell(Text(e.sucursal ?? 'Global', style: s)),
        DataCell(Text(e.registradoPor ?? '—', style: s)),
        DataCell(Text(e.monto.toCurrency(), style: s)),
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

enum _ExpenseAction { edit, delete }

class _ExpenseActions extends StatelessWidget {
  const _ExpenseActions({required this.onEdit, required this.onDelete});
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ExpenseAction>(
      icon: const Icon(Icons.more_vert, size: 18, color: Color(0xff71717A)),
      tooltip: '',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (action) {
        switch (action) {
          case _ExpenseAction.edit:
            onEdit();
          case _ExpenseAction.delete:
            onDelete();
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: _ExpenseAction.edit,
          height: 36,
          child: _MenuItem(icon: Icons.edit_outlined, label: 'Editar'),
        ),
        const PopupMenuItem(
          value: _ExpenseAction.delete,
          height: 36,
          child: _MenuItem(
            icon: Icons.delete_outlined,
            label: 'Eliminar',
            color: Color(0xffEF4444),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xff18181B);
    return Row(
      spacing: 8,
      children: [
        Icon(icon, size: 16, color: c),
        Text(label, style: TextStyle(fontSize: 13, color: c)),
      ],
    );
  }
}
