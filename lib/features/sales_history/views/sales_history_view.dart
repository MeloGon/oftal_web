import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/datatables/datatables.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/features/sales_history/views/widgets/filter_history_sales.dart';
import 'package:oftal_web/features/sales_history/views/widgets/sales_details_dialog.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SalesHistoryView extends ConsumerStatefulWidget {
  const SalesHistoryView({super.key});

  @override
  ConsumerState<SalesHistoryView> createState() => _SalesHistoryViewState();
}

class _SalesHistoryViewState extends ConsumerState<SalesHistoryView> {
  late SalesHistoryDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    final initialSales = ref.read(salesHistoryProvider).sales;
    _dataSource = SalesHistoryDataSource(
      sales: initialSales,
      context: context,
      ref: ref,
    );
    if (initialSales.isEmpty) {
      Future.microtask(
        () => ref.read(salesHistoryProvider.notifier).getSales(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final salesState = ref.watch(salesHistoryProvider);
    final salesNotifier = ref.read(salesHistoryProvider.notifier);
    _dataSource.update(salesState.sales, context);

    ref.listenLoading(
      salesHistoryProvider.select((s) => s.isLoading),
      context,
      onHidden: () {
        final state = ref.read(salesHistoryProvider);
        if (state.saleSelectedForDetails != null) {
          SalesDetailsDialog().show(
            context,
            state.saleDetails,
            state.saleSelectedForDetails!,
            ref,
          );
        }
      },
    );

    ref.listen(salesHistoryProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(
          () => ref.read(salesHistoryProvider.notifier).clearErrorMessage(),
        );
      }
    });

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // ─── Page header + actions ────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(child: _PageHeader()),
              ShadButton.outline(
                size: ShadButtonSize.sm,
                onPressed:
                    () => salesNotifier.exportPatientsToCsv(salesState.sales),
                child: const Row(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.fileDown, size: 14),
                    Text('Exportar CSV'),
                  ],
                ),
              ),
            ],
          ),

          // ─── Filters card ─────────────────────────────────
          ShadCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(child: FilterHistorySales()),
              ],
            ),
          ),

          // ─── Table card ───────────────────────────────────
          Expanded(
            child: ShadCard(
            padding: EdgeInsets.zero,
            child: TooltipVisibility(
                visible: false,
                child: PaginatedDataTable2(
                  headingRowHeight: 40,
                  showCheckboxColumn: false,
                  wrapInCard: false,
                  fixedLeftColumns: 1,
                  columnSpacing: 12,
                  columnResizingParameters: ColumnResizingParameters(
                    desktopMode: true,
                    realTime: false,
                    widgetColor: Theme.of(context).primaryColor,
                  ),
                  horizontalMargin: 16,
                  minWidth: 1500,
                  isHorizontalScrollBarVisible: true,
                  isVerticalScrollBarVisible: true,
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xffFAFAFA),
                  ),
                  source: _dataSource,
                  availableRowsPerPage: const [20],
                  rowsPerPage: salesState.rowsPerPage,
                  onRowsPerPageChanged:
                      (value) => salesNotifier.changeRowsPerPage(value ?? 20),
                  columns: [
                    const DataColumn2(
                      label: SizedBox.shrink(),
                      fixedWidth: 48,
                      isResizable: false,
                    ),
                    DataColumn2(
                      label: _ColHeader('Estado'),
                      fixedWidth: 52,
                      isResizable: false,
                    ),
                    DataColumn2(
                      label: _ColHeader('Folio'),
                      fixedWidth: 70,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('Paciente'),
                      fixedWidth: 210,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('Fecha'),
                      fixedWidth: 100,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('Vendedor'),
                      fixedWidth: 130,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('A cuenta'),
                      fixedWidth: 90,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('Resto'),
                      fixedWidth: 90,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('Descuento'),
                      fixedWidth: 90,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('Total'),
                      fixedWidth: 90,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('Total desc.'),
                      fixedWidth: 100,
                      isResizable: true,
                    ),
                    DataColumn2(
                      label: _ColHeader('Sucursal'),
                      fixedWidth: 100,
                      isResizable: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Local widgets ──────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        const Text(
          'Historial de Ventas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xff18181B),
          ),
        ),
        Text(
          'Consulta y filtra todas las ventas registradas',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      ],
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
