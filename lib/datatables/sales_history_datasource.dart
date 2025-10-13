import 'package:flutter/material.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class SalesHistoryDataSource extends DataTableSource {
  final List<SalesModel> sales;
  final BuildContext context;
  // final WidgetRef ref;

  SalesHistoryDataSource({
    required this.sales,
    required this.context,
    // required this.ref,
  });

  @override
  DataRow? getRow(int index) {
    final sale = sales[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(sale.folioSale.toString())),
        DataCell(Text(sale.patient.toString())),
        DataCell(Text(sale.date.toString())),
        DataCell(Text(sale.authorName.toString())),
        DataCell(Text(sale.account?.toCurrency() ?? '0')),
        DataCell(Text(sale.rest?.toCurrency() ?? '0')),
        DataCell(Text(sale.discount?.toCurrency() ?? '0')),
        DataCell(Text(sale.total?.toCurrency() ?? '0')),
        DataCell(Text(sale.totalWithDiscount?.toCurrency() ?? '0')),
        DataCell(Text(sale.branch.toString())),
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
