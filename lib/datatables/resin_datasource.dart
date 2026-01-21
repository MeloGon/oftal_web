import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_provider.dart';
import 'package:oftal_web/features/sell/views/widgets/resin_actions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class ResinDataSource extends DataTableSource {
  final List<ResinModel> resins;
  final BuildContext context;
  final WidgetRef ref;

  ResinDataSource({
    required this.resins,
    required this.context,
    required this.ref,
  });

  @override
  DataRow? getRow(int index) {
    final resin = resins[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(resin.description ?? '')),
        DataCell(Text(resin.design ?? '')),
        DataCell(Text(resin.line ?? '')),
        DataCell(Text(resin.material ?? '')),
        DataCell(Text(resin.technology ?? '')),
        DataCell(Text(resin.quantity?.toString() ?? '')),
        DataCell(Text('s./ ${resin.priceInternal?.toStringAsFixed(2) ?? ''}')),
        DataCell(Text('s./ ${resin.price?.toStringAsFixed(2) ?? ''}')),
        DataCell(
          ResinActions(
            resin: resin,
            onAddToCart: () {
              ref.read(sellProvider.notifier).selectItemToSell(resin);
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => resins.length;

  @override
  int get selectedRowCount => 0;
}
