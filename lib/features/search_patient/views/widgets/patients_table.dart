import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/datatables/datatables.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PatientsTable extends ConsumerWidget {
  const PatientsTable({super.key, required this.paginatorController});

  final PaginatorController paginatorController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPatientProvider);
    final notifier = ref.watch(searchPatientProvider.notifier);

    return Expanded(
      child: ShadCard(
        padding: EdgeInsets.zero,
        child: TooltipVisibility(
          visible: false,
          child: PaginatedDataTable2(
            controller: paginatorController,
            wrapInCard: false,
            fixedLeftColumns: 1,
            showCheckboxColumn: false,
            columnSpacing: 12,
            horizontalMargin: 16,
            isHorizontalScrollBarVisible: true,
            isVerticalScrollBarVisible: true,
            headingRowHeight: 44,
            headingRowColor: WidgetStateProperty.all(
              const Color(0xffFAFAFA),
            ),
            columns: [
              const DataColumn2(
                label: SizedBox.shrink(),
                fixedWidth: 48,
              ),
              DataColumn2(
                label: _ColHeader('Nombre'),
                size: ColumnSize.L,
                minWidth: 200,
              ),
              DataColumn2(
                label: _ColHeader('Fecha de registro'),
                size: ColumnSize.S,
                minWidth: 120,
              ),
              DataColumn2(
                label: _ColHeader('Sucursal'),
                size: ColumnSize.S,
                minWidth: 80,
              ),
              DataColumn2(
                label: _ColHeader('Teléfono'),
                size: ColumnSize.S,
                minWidth: 110,
              ),
            ],
            source: PatientsDataSource(
              patients: state.patients,
              context: context,
              ref: ref,
            ),
            availableRowsPerPage: const [10],
            rowsPerPage: state.rowsPerPage,
            onRowsPerPageChanged: (value) =>
                notifier.changeRowsPerPage(value ?? 10),
          ),
        ),
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
