import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/datatables/mounts_inventory_datasource.dart';
import 'package:oftal_web/features/settings/viewmodels/mounts/mounts_provider.dart';
import 'package:oftal_web/features/settings/views/mounts/widgets/add_mount_dialog.dart';
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
          AddMountDialog().show(context, ref).then((_) {
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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          // ─── Page header ─────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xffE4E4E7)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      'Inventario · Monturas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff18181B),
                      ),
                    ),
                    Text(
                      'Gestiona el catálogo de armazones y monturas',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff71717A),
                      ),
                    ),
                  ],
                ),
              ),
              ShadButton(
                onPressed: mountsNotifier.openAddMountDialog,
                child: const Row(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    Text('Añadir montura'),
                  ],
                ),
              ),
            ],
          ),

          // ─── Table card ───────────────────────────────────
          ShadCard(
            padding: EdgeInsets.zero,
            child: LoadingOverlay(
              isLoading: mountsState.isLoading,
              child: SizedBox(
                width: width * 0.9,
                height: 600,
                child: PaginatedDataTable2(
                  wrapInCard: false,
                  columnSpacing: 12,
                  horizontalMargin: 16,
                  headingRowHeight: 40,
                  minWidth: width * 0.88,
                  isHorizontalScrollBarVisible: true,
                  isVerticalScrollBarVisible: true,
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xffFAFAFA),
                  ),
                  columns: const [
                    DataColumn2(
                      label: _ColHeader('Marca'),
                      fixedWidth: 180,
                    ),
                    DataColumn2(
                      label: _ColHeader('Modelo'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: _ColHeader('Color'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: _ColHeader('Descripción'),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: _ColHeader('Optica'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: _ColHeader('Precio'),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: _ColHeader('Stock'),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: _ColHeader('Acciones'),
                      size: ColumnSize.S,
                    ),
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
                  onRowsPerPageChanged: (value) =>
                      mountsNotifier.changeRowsPerPage(value ?? 10),
                  onPageChanged: (rowIndex) => mountsNotifier.fetchPage(
                    offset: rowIndex,
                    limit: mountsState.rowsPerPage,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  const _ColHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xff52525B),
      ),
    );
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
