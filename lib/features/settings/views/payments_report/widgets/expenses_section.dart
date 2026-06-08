import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/settings/views/payments_report/widgets/payments_summary_row.dart';
import 'package:oftal_web/shared/widgets/data_col_header.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/expense_model.dart';

class ExpensesSummaryRow extends StatelessWidget {
  const ExpensesSummaryRow({
    super.key,
    required this.total,
    required this.byCategory,
  });
  final double total;
  final Map<String, double> byCategory;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        MetricCard(
          label: 'Total egresado',
          value: total.toCurrency(),
          icon: Icons.account_balance_wallet_outlined,
          iconColor: AppColors.error,
          iconBg: AppColors.errorBg,
          isTotal: true,
        ),
        ...byCategory.entries.map(
          (entry) => MetricCard(
            label: entry.key,
            value: entry.value.toCurrency(),
            icon: Icons.label_outline,
            iconColor: AppColors.gray500,
            iconBg: AppColors.gray100,
          ),
        ),
      ],
    );
  }
}

class ExpensesTable extends StatelessWidget {
  const ExpensesTable({super.key, required this.expenses});
  final List<ExpenseModel> expenses;

  static const _methodLabels = <String, String>{
    'efectivo': 'Efectivo',
    'tarjeta': 'Tarjeta',
    'transferencia': 'Transferencia',
    'nomina': 'Nómina',
    'otro': 'Otro',
  };

  static const _methodColors = <String, Color>{
    'efectivo': AppColors.efectivo,
    'tarjeta': AppColors.tarjeta,
    'transferencia': AppColors.transferencia,
    'nomina': AppColors.warning,
    'otro': AppColors.gray500,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.zinc50),
        headingRowHeight: 38,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 52,
        columnSpacing: 20,
        horizontalMargin: 16,
        columns: const [
          DataColumn(label: DataColHeader('Fecha')),
          DataColumn(label: DataColHeader('Categoría')),
          DataColumn(label: DataColHeader('Descripción')),
          DataColumn(label: DataColHeader('Método de pago')),
          DataColumn(label: DataColHeader('Sucursal')),
          DataColumn(label: DataColHeader('Comprobante')),
          DataColumn(label: DataColHeader('Registrado por')),
          DataColumn(label: DataColHeader('Monto'), numeric: true),
        ],
        rows:
            expenses.map((e) {
              final method = e.metodoPago;
              final methodLabel = _methodLabels[method] ?? method;
              final methodColor =
                  _methodColors[method] ?? AppColors.gray500;

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      e.fecha,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.zinc600,
                      ),
                    ),
                  ),
                  DataCell(
                    e.categoriaNombre != null
                        ? CategoryBadge(
                          nombre: e.categoriaNombre!,
                          color: e.categoriaColor,
                        )
                        : Text(
                          'Sin categoría',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                  ),
                  DataCell(
                    Text(
                      e.descripcion,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.zinc900,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: methodColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        methodLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: methodColor,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      e.sucursal ?? 'Global',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.zinc600,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      e.comprobante?.isNotEmpty == true ? e.comprobante! : '\u2014',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.zinc500,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      e.registradoPor ?? '\u2014',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.zinc600,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      e.monto.toCurrency(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }
}

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.nombre, this.color});
  final String nombre;
  final String? color;

  @override
  Widget build(BuildContext context) {
    Color dotColor = AppColors.indigo;
    if (color != null) {
      try {
        dotColor = Color(
          int.parse(color!.replaceFirst('#', '0xff')),
        );
      } catch (_) {}
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        Text(
          nombre,
          style: const TextStyle(fontSize: 12, color: AppColors.zinc900),
        ),
      ],
    );
  }
}
