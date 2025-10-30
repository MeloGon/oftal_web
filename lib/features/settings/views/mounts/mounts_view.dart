import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/datatables/mounts_inventory_datasource.dart';
import 'package:oftal_web/features/settings/viewmodels/mounts/mounts_provider.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MountsView extends ConsumerWidget {
  const MountsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final mountsState = ref.watch(mountsProvider);
    final mountsNotifier = ref.read(mountsProvider.notifier);

    return ShadCard(
      width: width * .9,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              context.pop();
            },
            child: Row(
              spacing: 10,
              children: [
                Icon(Icons.arrow_back_ios_new_outlined),
                Text('Monturas', style: ShadTheme.of(context).textTheme.h3),
                Spacer(),
                ShadButton(
                  child: Text('Añadir montura'),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Scrollbar(
                thumbVisibility: true,
                child: PaginatedDataTable(
                  primary: true,
                  headingRowHeight: 42,
                  dataRowMinHeight: 40,
                  columns: const [
                    DataColumn(label: Text('Marca')),
                    DataColumn(label: Text('Modelo')),
                    DataColumn(label: Text('Color')),
                    DataColumn(label: Text('Descripción')),
                    DataColumn(label: Text('Optica')),
                    DataColumn(label: Text('Precio')),
                    DataColumn(label: Text('Stock')),
                    DataColumn(label: Text('Acciones')),
                  ],
                  source: MountsInventoryDataSource(
                    pageItems: mountsState.mounts,
                    totalItems: mountsState.totalCount,
                    currentOffset: mountsState.offset,
                    isLoading: mountsState.isLoading,
                    context: context,
                    ref: ref,
                  ),
                  availableRowsPerPage: const [10, 50, 100],
                  rowsPerPage: mountsState.rowsPerPage,
                  onRowsPerPageChanged: (value) {
                    final limit = value ?? 10;
                    mountsNotifier.changeRowsPerPage(limit);
                  },
                  onPageChanged: (rowIndex) {
                    final limit = mountsState.rowsPerPage;
                    mountsNotifier.fetchPage(offset: rowIndex, limit: limit);
                  },
                ).box(width: width * .9),
              ),
              if (mountsState.isLoading)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ).paddingSymmetric(horizontal: 20, vertical: 10);
  }
}
