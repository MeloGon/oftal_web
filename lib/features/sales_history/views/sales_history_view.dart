import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/core/theme/app_text_styles.dart';
import 'package:oftal_web/datatables/datatables.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/features/sales_history/views/widgets/filter_history_sales.dart';
import 'package:oftal_web/features/sales_history/views/widgets/sales_details_dialog.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SalesHistoryView extends ConsumerWidget {
  const SalesHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final salesState = ref.watch(salesHistoryProvider);
    final salesNotifier = ref.watch(salesHistoryProvider.notifier);

    ref.listen(salesHistoryProvider, (previous, next) {
      if (next.isLoading && (previous?.isLoading ?? false) == false) {
        LoadingDialog().show(context);
      }
      if (!next.isLoading && (previous?.isLoading ?? false) == true) {
        if (context.mounted) {
          context.pop();
          if (next.saleSelectedForDetails != null) {
            SalesDetailsDialog().show(
              context,
              next.saleDetails,
              next.saleSelectedForDetails!,
              ref,
            );
          }
        }
      }
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(
          () => ref.read(salesHistoryProvider.notifier).clearErrorMessage(),
        );
      }
    });

    return Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            ShadCard(
              width: width * .9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ventas realizadas',
                    style: AppTextStyles(context).large,
                  ),
                  FilterHistorySales(),
                ],
              ),
            ),
            ShadCard(
              width: width * .9,
              child: TooltipVisibility(
                visible: false,
                child: PaginatedDataTable2(
                  headingRowHeight: 25,
                  showCheckboxColumn: false,
                  wrapInCard: false,
                  columnSpacing: 12,
                  columnResizingParameters: ColumnResizingParameters(
                    desktopMode: true,
                    realTime: true,
                    widgetColor: Theme.of(context).primaryColor,
                  ),
                  horizontalMargin: 12,
                  minWidth: 100000,
                  isHorizontalScrollBarVisible: true,
                  isVerticalScrollBarVisible: true,
                  headingRowColor: WidgetStateProperty.all(
                    Colors.black12,
                  ),
                  source: SalesHistoryDataSource(
                    sales: salesState.sales,
                    context: context,
                    ref: ref,
                  ),
                  availableRowsPerPage: [20],
                  rowsPerPage: salesState.rowsPerPage,
                  onRowsPerPageChanged:
                      (value) => salesNotifier.changeRowsPerPage(value ?? 20),
                  columns: [
                    DataColumn2(
                      label: Text(
                        'Folio',
                        style: AppTextStyles(context).small13Bold,
                      ),
                      fixedWidth: 70,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: Text(
                        'Paciente',
                        style: AppTextStyles(context).small13Bold,
                      ),
                      fixedWidth: 210,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: Text(
                        'Fecha',
                        style: AppTextStyles(context).small13Bold,
                      ),
                      fixedWidth: 100,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: Text(
                        'Vendedor',
                        style: AppTextStyles(context).small13Bold,
                      ),
                      fixedWidth: 100,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: Text(
                        'A cuenta',
                        style: AppTextStyles(context).small13Bold,
                      ),
                      fixedWidth: 100,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: Text(
                        'Resto',
                        style: AppTextStyles(context).small13Bold,
                      ),
                      fixedWidth: 100,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: Text(
                        'Descuento',
                        style: AppTextStyles(context).small13Bold,
                      ),
                      fixedWidth: 100,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: Text(
                        'Total',
                        style: AppTextStyles(context).small13Bold,
                      ),
                      fixedWidth: 100,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: Text(
                        'Total con descuento',
                        style: AppTextStyles(context).small13Bold,
                      ),
                      fixedWidth: 100,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: Text(
                        'Sucursal',
                        style: AppTextStyles(context).small13Bold,
                      ),
                      fixedWidth: 100,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: Text(
                        'Acciones',
                        style: AppTextStyles(context).small13Bold,
                      ),
                      fixedWidth: 100,
                      isResizable: true,
                    ),
                  ],
                ),
              ),
            ).expanded(),
            ShadButton(
              onPressed:
                  () => salesNotifier.exportPatientsToCsv(salesState.sales),
              child: const Text('Exportar CSV'),
            ),
          ],
        )
        .constrained(width: width * .9, height: height * .85)
        .paddingSymmetric(horizontal: 20, vertical: 20);
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
