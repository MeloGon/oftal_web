import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/search_patient/data/patients_datasource.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_provider.dart';
import 'package:oftal_web/shared/widgets/data_col_header.dart';
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
              AppColors.zinc50,
            ),
            columns: [
              const DataColumn2(
                label: SizedBox.shrink(),
                fixedWidth: 48,
              ),
              DataColumn2(
                label: DataColHeader('Nombre'),
                size: ColumnSize.L,
                minWidth: 200,
              ),
              DataColumn2(
                label: DataColHeader('Fecha de registro'),
                size: ColumnSize.S,
                minWidth: 120,
              ),
              DataColumn2(
                label: DataColHeader('Sucursal'),
                size: ColumnSize.S,
                minWidth: 80,
              ),
              DataColumn2(
                label: DataColHeader('Teléfono'),
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
