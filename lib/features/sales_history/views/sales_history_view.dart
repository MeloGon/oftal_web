import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/datatables/datatables.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/features/sales_history/views/widgets/filter_history_sales.dart';
import 'package:oftal_web/features/sales_history/views/widgets/edit_sale_dialog.dart';
import 'package:oftal_web/features/sales_history/views/widgets/sales_details_dialog.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SalesHistoryView extends ConsumerWidget {
  const SalesHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          if (next.isEditSaleDialogOpen && next.saleToEdit != null) {
            ref.read(salesHistoryProvider.notifier).closeEditSaleDialog();
            EditSaleDialog().show(
              context,
              ref,
              next.saleToEdit!,
              next.saleDetails,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(child: FilterHistorySales()),
                  ],
                ),
                const Divider(height: 1),
                const _ActionsLegend(),
              ],
            ),
          ),

          // ─── Table card ───────────────────────────────────
          ShadCard(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: height * 0.68,
              child: TooltipVisibility(
                visible: false,
                child: PaginatedDataTable2(
                  headingRowHeight: 40,
                  showCheckboxColumn: false,
                  wrapInCard: false,
                  columnSpacing: 12,
                  columnResizingParameters: ColumnResizingParameters(
                    desktopMode: true,
                    realTime: true,
                    widgetColor: Theme.of(context).primaryColor,
                  ),
                  horizontalMargin: 16,
                  minWidth: 1500,
                  isHorizontalScrollBarVisible: true,
                  isVerticalScrollBarVisible: true,
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xffFAFAFA),
                  ),
                  source: SalesHistoryDataSource(
                    sales: salesState.sales,
                    context: context,
                    ref: ref,
                  ),
                  availableRowsPerPage: const [20],
                  rowsPerPage: salesState.rowsPerPage,
                  onRowsPerPageChanged:
                      (value) => salesNotifier.changeRowsPerPage(value ?? 20),
                  columns: [
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
                    DataColumn2(
                      label: _ColHeader('Acciones'),
                      fixedWidth: 148,
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

class _ActionsLegend extends StatelessWidget {
  const _ActionsLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 6,
      children: [
        _LegendItem(icon: Icons.remove_red_eye_outlined, label: 'Ver detalles'),
        _LegendItem(icon: Icons.print_outlined, label: 'Imprimir recibo'),
        _LegendItem(
          icon: Icons.edit_outlined,
          label: 'Editar venta (Aun en fase experimental)',
          color: const Color(0xff0EA5E9),
        ),
        _LegendItem(
          icon: Icons.check_circle_outline,
          label: 'Finalizar venta',
          color: const Color(0xff16A34A),
        ),
        _LegendItem(icon: Icons.delete_outlined, label: 'Eliminar venta'),
        const _BadgeLegendItem(
          label: 'C',
          description: 'Cobrado',
          bg: Color(0xffDCFCE7),
          fg: Color(0xff16A34A),
        ),
        const _BadgeLegendItem(
          label: 'P',
          description: 'Pendiente',
          bg: Color(0xffFFF3CD),
          fg: Color(0xffD97706),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Icon(icon, size: 14, color: color ?? const Color(0xff71717A)),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xff71717A)),
        ),
      ],
    );
  }
}

class _BadgeLegendItem extends StatelessWidget {
  const _BadgeLegendItem({
    required this.label,
    required this.description,
    required this.bg,
    required this.fg,
  });
  final String label;
  final String description;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
        Text(
          description,
          style: const TextStyle(fontSize: 11, color: Color(0xff71717A)),
        ),
      ],
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
