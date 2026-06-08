import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/sales_model.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:oftal_web/shared/widgets/data_col_header.dart';
import 'summary_card.dart';

class SellerSection extends StatelessWidget {
  const SellerSection({
    super.key,
    required this.sellerName,
    required this.sales,
  });

  final String sellerName;
  final List<SalesModel> sales;

  @override
  Widget build(BuildContext context) {
    final total = sales.fold<double>(
      0,
      (sum, s) => sum + (s.totalWithDiscount ?? s.total ?? 0),
    );
    final totalAccount = sales.fold<double>(
      0,
      (sum, s) => sum + (s.account ?? 0),
    );
    final totalRest = sales.fold<double>(
      0,
      (sum, s) => sum + (s.rest ?? 0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        // ── Seller header ─────────────────────────────────────
        Row(
          spacing: 10,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            Expanded(
              child: Text(
                sellerName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.zinc900,
                ),
              ),
            ),
            Text(
              '${sales.length} venta${sales.length == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 12, color: AppColors.zinc500),
            ),
          ],
        ),

        // ── Summary cards ─────────────────────────────────────
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SummaryCard(
              label: 'Total ventas',
              value: total.toCurrency(),
              color: AppColors.primary,
              bg: AppColors.primaryBg,
              icon: Icons.sell_outlined,
            ),
            SummaryCard(
              label: 'A cuenta',
              value: totalAccount.toCurrency(),
              color: AppColors.success,
              bg: AppColors.successBg,
              icon: Icons.payments_outlined,
            ),
            SummaryCard(
              label: 'Saldo pendiente',
              value: totalRest.toCurrency(),
              color: AppColors.error,
              bg: AppColors.errorBg,
              icon: Icons.pending_outlined,
            ),
          ],
        ),

        // ── Sales table ───────────────────────────────────────
        ShadCard(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.zinc50),
              headingRowHeight: 38,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 48,
              columnSpacing: 20,
              horizontalMargin: 16,
              columns: const [
                DataColumn(label: DataColHeader('Folio')),
                DataColumn(label: DataColHeader('Paciente')),
                DataColumn(label: DataColHeader('Fecha')),
                DataColumn(
                  label: DataColHeader('Total'),
                  numeric: true,
                ),
                DataColumn(
                  label: DataColHeader('A cuenta'),
                  numeric: true,
                ),
                DataColumn(
                  label: DataColHeader('Saldo'),
                  numeric: true,
                ),
              ],
              rows:
                  sales.map((sale) {
                    final rest = sale.rest ?? 0;
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            sale.folioSale ?? '\u2014',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: AppColors.zinc600,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            sale.patient ?? '\u2014',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.zinc900,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _formatDate(sale.updatedDate ?? sale.date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.zinc600,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            (sale.totalWithDiscount ?? sale.total ?? 0)
                                .toCurrency(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.zinc900,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            (sale.account ?? 0).toCurrency(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.zinc600,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            rest.toCurrency(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  rest > 0
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                              color:
                                  rest > 0
                                      ? AppColors.error
                                      : AppColors.zinc500,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '\u2014';
    try {
      return DateFormat('dd/MM/yyyy').format(
        DateFormat('dd-MMM-yy', 'en_US').parse(raw),
      );
    } catch (_) {}
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(raw));
    } catch (_) {}
    return raw;
  }
}
