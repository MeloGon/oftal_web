import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/field_chip.dart';

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
                    FieldChip(label: 'Fecha', value: expense.fecha),
                    FieldChip(
                      label: 'Método',
                      value: _capitalize(expense.metodoPago),
                    ),
                    if (expense.comprobante != null &&
                        expense.comprobante!.isNotEmpty)
                      FieldChip(
                        label: 'Comprobante',
                        value: expense.comprobante!,
                      ),
                    if (expense.sucursal != null)
                      FieldChip(
                        label: 'Sucursal',
                        value: expense.sucursal!,
                      ),
                    if (expense.registradoPor != null)
                      FieldChip(
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

