import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/datatables/datatables.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:oftal_web/shared/widgets/custom_snackbar.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_provider.dart';
import 'package:oftal_web/features/search_patient/views/widgets/add_review_dialog.dart';
import 'package:oftal_web/features/search_patient/views/widgets/edit_patient_dialog.dart';
import 'package:oftal_web/features/search_patient/views/widgets/review_details_dialog.dart';
import 'package:oftal_web/shared/widgets/loading_dialog.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SearchPatientView extends ConsumerStatefulWidget {
  const SearchPatientView({super.key});

  @override
  ConsumerState<SearchPatientView> createState() => _SearchPatientViewState();
}

class _SearchPatientViewState extends ConsumerState<SearchPatientView> {
  final PaginatorController _paginatorController = PaginatorController();

  @override
  void dispose() {
    _paginatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final searchPatientState = ref.watch(searchPatientProvider);
    final searchPatientNotifier = ref.watch(searchPatientProvider.notifier);

    ref.listen(searchPatientProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        CustomSnackbar().show(
          context,
          next.snackbarConfig ??
              SnackbarConfigModel(title: 'Error', type: SnackbarEnum.error),
          next.errorMessage,
        );
        Future.microtask(
          () => ref
              .read(searchPatientProvider.notifier)
              .clearErrorMessage(),
        );
      }
      if (next.isAddViewMeasureDialogOpen &&
          previous?.isAddViewMeasureDialogOpen !=
              next.isAddViewMeasureDialogOpen) {
        if (context.mounted) {
          AddReviewDialog().show(context, ref).then((_) {
            ref
                .read(searchPatientProvider.notifier)
                .closeAddViewMeasureDialog();
          });
        }
      }
      if (next.isLoading && (previous?.isLoading ?? false) == false) {
        LoadingDialog().show(context);
      }
      if (!next.isLoading && (previous?.isLoading ?? false) == true) {
        if (context.mounted) context.pop();
      }
      if (next.isReviewDialogOpen && !(previous?.isReviewDialogOpen ?? false)) {
        if (context.mounted) {
          ref.read(searchPatientProvider.notifier).closeReviewDialog();
          ReviewDetailsDialog().show(context, next, ref);
        }
      }
      if (next.isEditDialogOpen && !(previous?.isEditDialogOpen ?? false)) {
        if (context.mounted && next.patientToEdit != null) {
          ref.read(searchPatientProvider.notifier).closeEditDialog();
          EditPatientDialog().show(context, ref, next.patientToEdit!);
        }
      }
    });

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          // ─── Page header ─────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              const Text(
                'Buscar Paciente',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff18181B),
                ),
              ),
              Text(
                'Busca y gestiona los registros de pacientes',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),

          // ─── Search card ─────────────────────────────────
          ShadCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 4,
              children: [
                ShadInput(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  placeholder:
                      const Text('Buscar por nombre del paciente...'),
                  controller: searchPatientNotifier.searchController,
                  leading: const Icon(LucideIcons.search, size: 16),
                  onSubmitted: (_) {
                    searchPatientNotifier.getPatients();
                    if (_paginatorController.isAttached) {
                      _paginatorController.goToFirstPage();
                    }
                  },
                  trailing: searchPatientNotifier.searchIsEmpty
                      ? null
                      : ShadButton.ghost(
                          height: 28,
                          width: 28,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            searchPatientNotifier.searchController.clear();
                            searchPatientNotifier.getPatients();
                            if (_paginatorController.isAttached) {
                              _paginatorController.goToFirstPage();
                            }
                          },
                          child: const Icon(LucideIcons.x, size: 14),
                        ),
                ),
              ],
            ),
          ),

          // ─── Results table ───────────────────────────────
          if (searchPatientState.patients.isNotEmpty)
            ShadCard(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: height * 0.65,
                child: TooltipVisibility(
                  visible: false,
                  child: PaginatedDataTable2(
                    controller: _paginatorController,
                    wrapInCard: false,
                    columnSpacing: 12,
                    horizontalMargin: 16,
                    isHorizontalScrollBarVisible: true,
                    isVerticalScrollBarVisible: true,
                    headingRowHeight: 44,
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xffFAFAFA),
                    ),
                    columns: [
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
                      DataColumn2(
                        label: _ColHeader('Acciones'),
                        size: ColumnSize.S,
                        minWidth: 130,
                      ),
                    ],
                    source: PatientsDataSource(
                      patients: searchPatientState.patients,
                      context: context,
                      ref: ref,
                    ),
                    availableRowsPerPage: const [10],
                    rowsPerPage: searchPatientState.rowsPerPage,
                    onRowsPerPageChanged: (value) =>
                        searchPatientNotifier.changeRowsPerPage(value ?? 10),
                  ),
                ),
              ),
            )
          else
            ShadCard(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  spacing: 8,
                  children: [
                    Icon(
                      LucideIcons.users,
                      size: 36,
                      color: Colors.grey.shade300,
                    ),
                    Text(
                      'Busca un paciente por su nombre',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
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
