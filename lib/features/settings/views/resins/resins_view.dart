import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/data/resins_inventory_datasource.dart';
import 'package:oftal_web/features/settings/viewmodels/resins/resins_provider.dart';
import 'package:oftal_web/features/settings/views/resins/widgets/add_resin_dialog.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ResinsView extends ConsumerWidget {
  const ResinsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final resinsState = ref.watch(resinsProvider);
    final resinsNotifier = ref.read(resinsProvider.notifier);

    ref.listen(resinsProvider, (previous, next) {
      if (next.isAddResinDialogOpen &&
          previous?.isAddResinDialogOpen != next.isAddResinDialogOpen) {
        if (context.mounted) {
          AddResinDialog().show(context, ref).then((_) {
            ref.read(resinsProvider.notifier).closeAddResinDialog();
          });
        }
      }
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(
          () => ref.read(resinsProvider.notifier).clearErrorMessage(),
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
                      'Inventario · Resinas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc900,
                      ),
                    ),
                    Text(
                      'Gestiona el catálogo de resinas y lentes',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.zinc500,
                      ),
                    ),
                  ],
                ),
              ),
              ShadButton(
                onPressed: resinsNotifier.openAddResinDialog,
                child: const Row(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    Text('Añadir resina'),
                  ],
                ),
              ),
            ],
          ),

          // ─── Table card ───────────────────────────────────
          Expanded(
           child: ShadCard(
            padding: EdgeInsets.zero,
            child: LoadingOverlay(
              isLoading: resinsState.isLoading,
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
                      label: DataColHeader('Descripción'),
                      fixedWidth: 230,
                    ),
                    DataColumn2(
                      label: DataColHeader('Diseño'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: DataColHeader('Linea'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: DataColHeader('Material'),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: DataColHeader('Tecnología'),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: DataColHeader('Cant.'),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: DataColHeader('P. Interno'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: DataColHeader('Precio'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: DataColHeader('Acciones'),
                      size: ColumnSize.M,
                    ),
                  ],
                  source: ResinInventoryDataSource(
                    pageItems: resinsState.resins,
                    totalItems: resinsState.totalCount,
                    currentOffset: resinsState.offset,
                    isLoading: resinsState.isLoading,
                    context: context,
                    ref: ref,
                  ),
                  availableRowsPerPage: const [10, 20, 30, 50],
                  rowsPerPage: resinsState.rowsPerPage,
                  onRowsPerPageChanged: (value) =>
                      resinsNotifier.changeRowsPerPage(value ?? 10),
                  onPageChanged: (rowIndex) => resinsNotifier.fetchPage(
                    offset: rowIndex,
                    limit: resinsState.rowsPerPage,
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
