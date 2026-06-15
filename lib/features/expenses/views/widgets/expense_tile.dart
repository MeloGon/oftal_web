import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onEdit,
    required this.onDelete,
  });
  final List<ExpenseModel> expenses;
  final void Function(ExpenseModel) onEdit;
  final void Function(ExpenseModel) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: expenses.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) => ExpenseTile(
        expense: expenses[i],
        onEdit: () => onEdit(expenses[i]),
        onDelete: () => onDelete(expenses[i]),
      ),
    );
  }
}

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });
  final ExpenseModel expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final catColor = _hexToColor(expense.categoriaColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        spacing: 14,
        children: [
          // ─ Ícono categoría ─────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 16,
              color: catColor,
            ),
          ),

          // ─ Info ────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Flexible(
                      child: Text(
                        expense.descripcion,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.zinc900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        expense.categoriaNombre ?? 'Sin categoría',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: catColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _FieldChip(label: 'Fecha', value: expense.fecha),
                    _FieldChip(
                      label: 'Método',
                      value: _capitalize(expense.metodoPago),
                    ),
                    if (expense.comprobante != null &&
                        expense.comprobante!.isNotEmpty)
                      _FieldChip(
                        label: 'Comprobante',
                        value: expense.comprobante!,
                      ),
                    if (expense.sucursal != null)
                      _FieldChip(
                        label: 'Sucursal',
                        value: expense.sucursal!,
                      ),
                    if (expense.registradoPor != null)
                      _FieldChip(
                        label: 'Por',
                        value: expense.registradoPor!,
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ─ Monto ───────────────────────────────────────
          Text(
            expense.monto.toCurrency(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),

          // ─ Actions ─────────────────────────────────────
          PopupMenuButton<_Action>(
            icon: Icon(Icons.more_vert, size: 18, color: AppColors.zinc500),
            tooltip: '',
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onSelected: (action) {
              switch (action) {
                case _Action.edit:
                  onEdit();
                case _Action.delete:
                  onDelete();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: _Action.edit,
                height: 36,
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: AppColors.zinc900),
                    Text('Editar',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.zinc900)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _Action.delete,
                height: 36,
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.delete_outlined, size: 16, color: AppColors.error),
                    Text('Eliminar',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _Action { edit, delete }

// ─── Private helpers ─────────────────────────────────────────────────────────

Color _hexToColor(String? hex) {
  if (hex == null || hex.isEmpty) return AppColors.indigo;
  final clean = hex.replaceFirst('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

class _FieldChip extends StatelessWidget {
  const _FieldChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.zinc100,
        borderRadius: BorderRadius.circular(5),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.zinc500,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.zinc700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
