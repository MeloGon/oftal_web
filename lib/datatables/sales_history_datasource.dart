import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_text_styles.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/features/sales_history/views/widgets/sales_history_actions.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class SalesHistoryDataSource extends DataTableSource {
  final List<SalesModel> sales;
  final BuildContext context;
  final WidgetRef ref;

  SalesHistoryDataSource({
    required this.sales,
    required this.context,
    required this.ref,
  });

  Widget cell(String label, SalesModel sale) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onDoubleTap: () {
      ref.read(salesHistoryProvider.notifier).selectSaleForDetails(sale);
      ref.read(salesHistoryProvider.notifier).getSalesDetails();
    },
    child: Text(label),
  );

  void doubleTap(SalesModel sale) {
    ref.read(salesHistoryProvider.notifier).selectSaleForDetails(sale);
    ref.read(salesHistoryProvider.notifier).getSalesDetails();
  }

  @override
  DataRow? getRow(int index) {
    final sale = sales[index];

    return DataRow.byIndex(
      onSelectChanged: (value) {},
      index: index,
      cells: [
        DataCell(_StatusBadge(isPaid: (sale.rest ?? 0) == 0)),
        DataCell(
          Text(
            sale.folioSale.toString(),
            style: AppTextStyles(context).small13,
          ),
          onDoubleTap: () => doubleTap(sale),
        ),
        DataCell(
          Text(sale.patient.toString(), style: AppTextStyles(context).small13),
          onDoubleTap: () => doubleTap(sale),
        ),
        DataCell(
          Text(sale.date.toString(), style: AppTextStyles(context).small13),
          onDoubleTap: () => doubleTap(sale),
        ),
        DataCell(
          Text(
            sale.authorName.toString(),
            style: AppTextStyles(context).small13,
          ),
          onDoubleTap: () => doubleTap(sale),
        ),
        DataCell(
          Text(
            sale.account?.toCurrency() ?? '0',
            style: AppTextStyles(context).small13,
          ),
          onDoubleTap: () => doubleTap(sale),
        ),
        DataCell(
          Text(
            sale.rest?.toCurrency() ?? '0',
            style: AppTextStyles(context).small13,
          ),
          onDoubleTap: () => doubleTap(sale),
        ),
        DataCell(
          Text(
            sale.discount?.toCurrency() ?? '0',
            style: AppTextStyles(context).small13,
          ),
          onDoubleTap: () => doubleTap(sale),
        ),
        DataCell(
          Text(
            sale.total?.toCurrency() ?? '0',
            style: AppTextStyles(context).small13,
          ),
          onDoubleTap: () => doubleTap(sale),
        ),
        DataCell(
          Text(
            sale.totalWithDiscount?.toCurrency() ?? '0',
            style: AppTextStyles(context).small13,
          ),
          onDoubleTap: () => doubleTap(sale),
        ),
        DataCell(
          Text(sale.branch.toString(), style: AppTextStyles(context).small13),
          onDoubleTap: () => doubleTap(sale),
        ),

        DataCell(
          SalesHistoryActions(
            sale: sale,
            onViewDetails: () {
              ref
                  .read(salesHistoryProvider.notifier)
                  .selectSaleForDetails(sale);
              ref.read(salesHistoryProvider.notifier).getSalesDetails();
            },
            onPrintSale: () async {
              ref
                  .read(salesHistoryProvider.notifier)
                  .selectSaleForDetails(sale);
              await ref
                  .read(salesHistoryProvider.notifier)
                  .getSalesDetails()
                  .then((value) async {
                    await ref
                        .read(salesHistoryProvider.notifier)
                        .generatePdf(sale);
                  });
            },
            onDeleteSale: () async {
              await ref.read(salesHistoryProvider.notifier).deleteSale(sale);
            },
            onEditSale: () =>
                ref.read(salesHistoryProvider.notifier).selectSaleForEdit(sale),
            onFinalizeSale: () =>
                ref.read(salesHistoryProvider.notifier).finalizeSale(sale),
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
