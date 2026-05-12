import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/datatables/resins_inventory_datasource.dart';
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
                      'Inventario · Resinas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff18181B),
                      ),
                    ),
                    Text(
                      'Gestiona el catálogo de resinas y lentes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff71717A),
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
                    const Color(0xffFAFAFA),
                  ),
                  columns: const [
                    DataColumn2(
                      label: _ColHeader('Descripción'),
                      fixedWidth: 230,
                    ),
                    DataColumn2(
                      label: _ColHeader('Diseño'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: _ColHeader('Linea'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: _ColHeader('Material'),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: _ColHeader('Tecnología'),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: _ColHeader('Cant.'),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: _ColHeader('P. Interno'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: _ColHeader('Precio'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: _ColHeader('Acciones'),
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
