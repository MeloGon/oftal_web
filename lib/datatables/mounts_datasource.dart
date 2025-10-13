import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_provider.dart';
import 'package:oftal_web/features/sell/views/widgets/mount_actions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class MountsDataSource extends DataTableSource {
  final List<MountModel> mounts;
  final BuildContext context;
  final WidgetRef ref;

  MountsDataSource({
    required this.mounts,
    required this.context,
    required this.ref,
  });

  @override
  DataRow? getRow(int index) {
    final mount = mounts[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(mount.brand)),
        DataCell(Text(mount.model)),
        DataCell(Text(mount.color)),
        DataCell(Text(mount.description)),
        DataCell(Text(mount.opticName)),
        DataCell(Text(mount.price.toString())),
        DataCell(
          MountActions(
            mount: mount,
            onAddToCart: () {
              ref.read(sellProvider.notifier).selectItemToSell(mount);
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => mounts.length;

  @override
  int get selectedRowCount => 0;
}
