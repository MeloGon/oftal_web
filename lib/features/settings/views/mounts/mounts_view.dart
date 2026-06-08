import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/data/mounts_inventory_datasource.dart';
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
                  side: const BorderSide(color: AppColors.zinc200),
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
                        color: AppColors.zinc900,
                      ),
                    ),
                    Text(
                      'Gestiona el catálogo de armazones y monturas',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.zinc500,
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

          // ─── Search bar ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  child: ShadInput(
                    controller: mountsNotifier.searchController,
                    placeholder: const Text('Buscar por marca o modelo...'),
                    leading: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.search, size: 16, color: AppColors.zinc500),
                    ),
                    trailing: mountsState.isSearchMode
                        ? GestureDetector(
                            onTap: mountsNotifier.clearSearch,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.close, size: 16, color: AppColors.zinc500),
                            ),
                          )
                        : null,
                    onSubmitted: (_) => mountsNotifier.searchMounts(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ShadButton.outline(
                onPressed: mountsNotifier.searchMounts,
                child: const Text('Buscar'),
              ),
            ],
          ),

          // ─── Table card ───────────────────────────────────
          Expanded(
           child: ShadCard(
            padding: EdgeInsets.zero,
            child: LoadingOverlay(
              isLoading: mountsState.isLoading,
              child: PaginatedDataTable2(
                  wrapInCard: false,
                  columnSpacing: 12,
                  horizontalMargin: 16,
                  headingRowHeight: 40,
                  minWidth: width * 0.88,
                  isHorizontalScrollBarVisible: true,
                  isVerticalScrollBarVisible: true,
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.zinc50,
                  ),
                  columns: const [
                    DataColumn2(
                      label: DataColHeader('Marca'),
                      fixedWidth: 180,
                    ),
                    DataColumn2(
                      label: DataColHeader('Modelo'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: DataColHeader('Color'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: DataColHeader('Descripción'),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: DataColHeader('Optica'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: DataColHeader('Precio'),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: DataColHeader('Stock'),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: DataColHeader('Acciones'),
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
