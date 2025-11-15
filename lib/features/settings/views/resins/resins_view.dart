import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/datatables/resins_inventory_datasource.dart';
import 'package:oftal_web/features/settings/viewmodels/resins/resins_provider.dart';
import 'package:oftal_web/features/settings/views/resins/widgets/add_resin_dialog.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
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
          AddResinDialog().show(context, ref).then((value) {
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

    return ShadCard(
      width: width * .9,

      child: Column(
        children: [
          Row(
            spacing: 10,
            children: [
              IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: Icon(Icons.arrow_back_ios_new_outlined),
              ),
              Text('Resinas', style: ShadTheme.of(context).textTheme.h3),
              Spacer(),
              ShadButton(
                child: Text('Añadir resina'),
                onPressed: () {
                  resinsNotifier.openAddResinDialog();
                },
              ),
            ],
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
                    DataColumn(label: Text('Descripción')),
                    DataColumn(label: Text('Diseño')),
                    DataColumn(label: Text('Linea')),
                    DataColumn(label: Text('Material')),
                    DataColumn(label: Text('Tecnologia')),
                    DataColumn(label: Text('Cantidad')),
                    DataColumn(label: Text('Precio interno')),
                    DataColumn(label: Text('Precio')),
                    DataColumn(label: Text('Acciones')),
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
                  onRowsPerPageChanged: (value) {
                    resinsNotifier.changeRowsPerPage(value ?? 5);
                  },
                  onPageChanged: (rowIndex) {
                    final limit = resinsState.rowsPerPage;
                    resinsNotifier.fetchPage(offset: rowIndex, limit: limit);
                  },
                ),
              ).box(
                width: width * .9,
              ),
              if (resinsState.isLoading)
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
