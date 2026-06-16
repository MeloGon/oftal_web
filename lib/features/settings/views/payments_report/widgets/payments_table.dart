import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/daily_payment_model.dart';
import 'package:oftal_web/shared/widgets/data_col_header.dart';

class PaymentsTable extends StatelessWidget {
  const PaymentsTable({super.key, required this.payments});

  final List<DailyPaymentModel> payments;

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
          DataColumn(label: DataColHeader('Paciente')),
          DataColumn(label: DataColHeader('Folio')),
          DataColumn(label: DataColHeader('Método de pago')),
          DataColumn(label: DataColHeader('Notas')),
          DataColumn(label: DataColHeader('Monto'), numeric: true),
          DataColumn(label: DataColHeader('Total venta'), numeric: true),
          DataColumn(label: DataColHeader('Saldo'), numeric: true),
        ],
        rows:
            payments.map((p) {
              final method = p.metodoPago ?? 'otro';
              final methodLabel = _methodLabels[method] ?? method;
              final methodColor =
                  _methodColors[method] ?? AppColors.gray500;

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      p.fechaPago,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.zinc600,
                      ),
                    ),
                  ),
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.paciente ?? '\u2014',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.zinc900,
                          ),
                        ),
                        if (p.sucursal != null)
                          Text(
                            'Sucursal: ${p.sucursal}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.zinc500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      p.folioRemision ?? p.idRemision,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.zinc600,
                        fontFamily: 'monospace',
                      ),
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
                      p.notas?.isNotEmpty == true ? p.notas! : '\u2014',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.zinc500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  DataCell(
                    Text(
                      p.monto.toCurrency(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc900,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      p.totalVenta?.toCurrency() ?? '—',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.zinc600,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      p.saldoPendiente?.toCurrency() ?? '—',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: (p.saldoPendiente ?? 0) > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: (p.saldoPendiente ?? 0) > 0
                            ? AppColors.error
                            : AppColors.zinc500,
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
