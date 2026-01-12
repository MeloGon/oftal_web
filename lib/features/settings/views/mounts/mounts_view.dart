import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/datatables/mounts_inventory_datasource.dart';
import 'package:oftal_web/features/settings/viewmodels/mounts/mounts_provider.dart';
import 'package:oftal_web/features/settings/views/mounts/widgets/add_mount_dialog.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MountsView extends ConsumerWidget {
  const MountsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final mountsState = ref.watch(mountsProvider);
    final mountsNotifier = ref.read(mountsProvider.notifier);

    ref.listen(mountsProvider, (previous, next) {
      if (next.isAddMountDialogOpen &&
          previous?.isAddMountDialogOpen != next.isAddMountDialogOpen) {
        if (context.mounted) {
          AddMountDialog().show(context, ref).then((value) {
            ref.read(mountsProvider.notifier).closeAddMountDialog();
          });
        }
      }

      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(
          () => ref.read(mountsProvider.notifier).clearErrorMessage(),
        );
      }
    });

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
                  onPressed: () {
                    mountsNotifier.openAddMountDialog();
                  },
                ),
              ],
            ),
          ),
          Stack(
            children: [
              SizedBox(
                width: width * .9,
                height: 600,
                child: PaginatedDataTable2(
                  // headingRowHeight: 42,
                  wrapInCard: false,
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: width * .9,
                  isHorizontalScrollBarVisible: true,
                  isVerticalScrollBarVisible: true,
                  columns: const [
                    DataColumn2(label: Text('Marca'), fixedWidth: 200),
                    DataColumn2(label: Text('Modelo'), size: ColumnSize.M),
                    DataColumn2(label: Text('Color'), size: ColumnSize.M),
                    DataColumn2(label: Text('Descripción'), size: ColumnSize.L),
                    DataColumn2(label: Text('Optica'), size: ColumnSize.M),
                    DataColumn2(label: Text('Precio'), size: ColumnSize.M),
                    DataColumn2(label: Text('Stock'), size: ColumnSize.S),
                    DataColumn2(label: Text('Acciones'), size: ColumnSize.M),
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
                ),
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

void _showSnackbar(
  BuildContext context,
  SnackbarConfigModel? snackbarConfig,
  String errorMessage,
) {
  CustomSnackbar().show(
    context,
    snackbarConfig ??
        SnackbarConfigModel(title: 'Error', type: SnackbarEnum.error),
    errorMessage,
  );
}
