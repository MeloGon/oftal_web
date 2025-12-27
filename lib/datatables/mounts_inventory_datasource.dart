import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/settings/viewmodels/mounts/mounts_provider.dart';
import 'package:oftal_web/features/settings/views/mounts/widgets/mounts_inventory_actions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class MountsInventoryDataSource extends DataTableSource {
  final List<MountModel> pageItems;
  final int totalItems;
  final int currentOffset;
  final bool isLoading;
  final BuildContext context;
  final WidgetRef ref;

  MountsInventoryDataSource({
    required this.pageItems,
    required this.totalItems,
    required this.currentOffset,
    required this.isLoading,
    required this.context,
    required this.ref,
  });

  @override
  DataRow? getRow(int index) {
    // Mapea el índice absoluto al índice local de la página actual
    final localIndex = index - currentOffset;
    if (localIndex < 0 || localIndex >= pageItems.length) {
      // Mientras se carga la nueva página, evita null (que pinta loaders por celda)
      // Devuelve una fila placeholder con celdas vacías
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
        ],
      );
    }
    final mount = pageItems[localIndex];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(mount.brand.toUpperCase())),
        DataCell(Text(mount.model.toUpperCase())),
        DataCell(Text(mount.color.toUpperCase())),
        DataCell(Text(mount.description.toUpperCase())),
        DataCell(Text(mount.opticName)),
        DataCell(Text('s./ ${mount.price.toStringAsFixed(2)}')),
        DataCell(Text(mount.stock.toString())),
        DataCell(
          MountsInventoryActions(
            mount: mount,
            onDeleteMount: () {
              ref.read(mountsProvider.notifier).deleteMount(mount.id);
            },
            onEditMount: () {
              ref.read(mountsProvider.notifier).editMount(mount);
            },
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
