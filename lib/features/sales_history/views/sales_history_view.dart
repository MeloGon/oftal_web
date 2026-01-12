import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/enums/enums.dart';
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
      children: [
        ShadCard(
          width: width * .9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(
                'Ventas realizadas',
                style: ShadTheme.of(context).textTheme.h2,
              ),
              Text(
                'En este modulo puedes realizar opciones como:',
              ),
              Text(
                '\u2022 Ver las ventas realizadas',
              ),
              Text(
                '\u2022 Filtrar las ventas realizadas por folio, paciente o fecha',
              ),
              Text(
                '\u2022 Ver los detalles de una venta',
              ),
            ],
          ),
        ),
        ShadCard(
          width: MediaQuery.sizeOf(context).width * .9,
          height: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FilterHistorySales(),
              PaginatedDataTable2(
                wrapInCard: false,
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: width * .9,
                isHorizontalScrollBarVisible: true,
                isVerticalScrollBarVisible: true,
                headingRowColor: WidgetStateProperty.all(Colors.black12),
                columns: const [
                  DataColumn2(
                    label: Text('Folio'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(label: Text('Paciente'), fixedWidth: 200),
                  DataColumn2(
                    label: Text('Fecha'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Vendedor'),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text('A cuenta'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Resto'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Descuento'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Total'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Total con descuento'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Sucursal'),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(label: Text('Acciones'), fixedWidth: 100),
                ],
                source: SalesHistoryDataSource(
                  sales: salesState.sales,
                  context: context,
                  ref: ref,
                ),
                availableRowsPerPage: [10, 20, 50],
                rowsPerPage: salesState.rowsPerPage,
                onRowsPerPageChanged:
                    (value) => salesNotifier.changeRowsPerPage(value ?? 10),
              ).paddingOnly(top: 20).expanded(),
            ],
          ).paddingOnly(top: 20),
        ),
        ShadButton(
          onPressed: () => salesNotifier.exportPatientsToCsv(salesState.sales),
          child: const Text('Exportar CSV'),
        ),
      ],
    ).paddingSymmetric(horizontal: 20, vertical: 20);
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
