import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/features/sales_history/views/widgets/register_payment_dialog.dart';
import 'package:oftal_web/features/sales_history/views/widgets/sales_history_actions.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class SalesHistoryDataSource extends DataTableSource {
  List<SalesModel> sales;
  BuildContext context;
  final WidgetRef ref;

  // Cached once per class — avoids GoogleFonts + ShadTheme lookups per cell
  static final _cellStyle = TextStyle(
    fontSize: 13,
    fontFamily: GoogleFonts.poppins().fontFamily,
  );

  SalesHistoryDataSource({
    required this.sales,
    required this.context,
    required this.ref,
  });

  /// Call from build() to refresh data without recreating the source.
  /// Only triggers notifyListeners() when the sales list actually changes.
  void update(List<SalesModel> newSales, BuildContext ctx) {
    context = ctx;
    if (identical(sales, newSales)) return;
    sales = newSales;
    notifyListeners();
  }

  void _openDetails(SalesModel sale) {
    ref.read(salesHistoryProvider.notifier).selectSaleForDetails(sale);
  }

  @override
  DataRow? getRow(int index) {
    final sale = sales[index];
    final s = _cellStyle;

    return DataRow.byIndex(
      onSelectChanged: (value) {},
      index: index,
      cells: [
        DataCell(_StatusBadge(isPaid: (sale.rest ?? 0) == 0)),
        DataCell(
          Text(sale.folioSale.toString(), style: s),
          onDoubleTap: () => _openDetails(sale),
        ),
        DataCell(
          Text(sale.patient.toString(), style: s),
          onDoubleTap: () => _openDetails(sale),
        ),
        DataCell(
          Text(sale.date.toString(), style: s),
          onDoubleTap: () => _openDetails(sale),
        ),
        DataCell(
          Text(sale.authorName.toString(), style: s),
          onDoubleTap: () => _openDetails(sale),
        ),
        DataCell(
          Text(sale.account?.toCurrency() ?? '0', style: s),
          onDoubleTap: () => _openDetails(sale),
        ),
        DataCell(
          Text(
            (sale.rest ?? 0) == 0 ? '—' : sale.rest!.toCurrency(),
            style: s,
          ),
          onDoubleTap: () => _openDetails(sale),
        ),
        DataCell(
          Text(
            (sale.discount ?? 0) == 0 ? '—' : sale.discount!.toCurrency(),
            style: s,
          ),
          onDoubleTap: () => _openDetails(sale),
        ),
        DataCell(
          Text(sale.total?.toCurrency() ?? '0', style: s),
          onDoubleTap: () => _openDetails(sale),
        ),
        DataCell(
          Text(sale.totalWithDiscount?.toCurrency() ?? '0', style: s),
          onDoubleTap: () => _openDetails(sale),
        ),
        DataCell(
          Text(sale.branch.toString(), style: s),
          onDoubleTap: () => _openDetails(sale),
        ),
        DataCell(
          SalesHistoryActions(
            sale: sale,
            onViewDetails: () => _openDetails(sale),
            onPrintSale: () async {
              _openDetails(sale);
              await ref
                  .read(salesHistoryProvider.notifier)
                  .getSalesDetails()
                  .then((_) => ref
                      .read(salesHistoryProvider.notifier)
                      .generatePdf(sale));
            },
            onDeleteSale: () =>
                ref.read(salesHistoryProvider.notifier).deleteSale(sale),
            onFinalizeSale: () =>
                ref.read(salesHistoryProvider.notifier).finalizeSale(sale),
            onRegisterPayment: () =>
                RegisterPaymentDialog().show(context, ref, sale),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => sales.length;

  @override
  int get selectedRowCount => 0;
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isPaid});
  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xffDCFCE7) : const Color(0xffFFF3CD),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isPaid ? 'C' : 'P',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isPaid ? const Color(0xff16A34A) : const Color(0xffD97706),
        ),
      ),
    );
  }
}
