import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/settings/views/resins/widgets/resins_inventory_actions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class ResinInventoryDataSource extends DataTableSource {
  final List<ResinModel> pageItems;
  final int totalItems;
  final int currentOffset;
  final bool isLoading;
  final BuildContext context;
  final WidgetRef ref;

  ResinInventoryDataSource({
    required this.pageItems,
    required this.totalItems,
    required this.currentOffset,
    required this.isLoading,
    required this.context,
    required this.ref,
  });

  @override
  DataRow? getRow(int index) {
    final localIndex = index - currentOffset;
    if (localIndex < 0 || localIndex >= pageItems.length) {
      return DataRow.byIndex(
        index: index,
        cells: const [
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
        ],
      );
    }
    final resin = pageItems[localIndex];
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
          ResinInventoryActions(
            resin: resin,
            // onAddToCart: () {
            //   ref.read(sellProvider.notifier).selectItemToSell(resin);
            // },
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => totalItems;

  @override
  int get selectedRowCount => 0;
}
