import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/theme/app_text_styles.dart';
import 'package:oftal_web/datatables/datatables.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_provider.dart';
import 'package:oftal_web/features/search_patient/views/widgets/add_review_dialog.dart';
import 'package:oftal_web/features/search_patient/views/widgets/review_details_dialog.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
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
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final searchPatientState = ref.watch(searchPatientProvider);
    final searchPatientNotifier = ref.watch(searchPatientProvider.notifier);

    ref.listen(searchPatientProvider, (previous, next) {
      if (next.isAddViewMeasureDialogOpen &&
          previous?.isAddViewMeasureDialogOpen !=
              next.isAddViewMeasureDialogOpen) {
        if (context.mounted) {
          AddReviewDialog()
              .show(
                context,
                ref,
              )
              .then((value) {
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
        if (context.mounted) {
          context.pop();
          if (next.reviews.isNotEmpty && previous?.reviews != next.reviews) {
            if (context.mounted) {
              ReviewDetailsDialog().show(context, next);
            }
          }
        }
      }
    });

    return Column(
      spacing: 24,
      children: [
        ShadCard(
          width: width * .9,
          height: height * .8,
          child: Column(
            children: [
              ShadInputFormField(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                placeholder: Text('Ingrese el nombre del paciente'),
                controller: searchPatientNotifier.searchController,
                leading: Icon(LucideIcons.search),
                onSubmitted: (_) {
                  searchPatientNotifier.getPatients();
                  if (_paginatorController.isAttached) {
                    _paginatorController.goToFirstPage();
                  }
                },
                trailing:
                    searchPatientNotifier.searchIsEmpty
                        ? null
                        : ShadButton(
                          onPressed: () {
                            searchPatientNotifier.searchController.clear();
                            searchPatientNotifier.getPatients();
                            if (_paginatorController.isAttached) {
                              _paginatorController.goToFirstPage();
                            }
                          },
                          height: 30,
                          child: Icon(Icons.close),
                        ),
              ),
              if (searchPatientState.patients.isNotEmpty)
                TooltipVisibility(
                  visible: false,
                  child: PaginatedDataTable2(
                    controller: _paginatorController,
                    wrapInCard: false,
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    isHorizontalScrollBarVisible: true,
                    isVerticalScrollBarVisible: true,
                    headingRowHeight: 42,
                    headingRowColor: WidgetStateProperty.all(Colors.black12),
                    columns: [
                      DataColumn2(
                        label: Text(
                          'Nombre',
                          style: AppTextStyles(context).small13Bold,
                        ),
                        size: ColumnSize.L,
                        minWidth: 200,
                      ),
                      DataColumn2(
                        label: Text(
                          'Fecha de registro',
                          style: AppTextStyles(context).small13Bold,
                        ),
                        size: ColumnSize.S,
                        minWidth: 100,
                      ),
                      DataColumn2(
                        label: Text(
                          'Sucursal',
                          style: AppTextStyles(context).small13Bold,
                        ),
                        size: ColumnSize.S,
                        minWidth: 60,
                      ),
                      DataColumn2(
                        label: Text(
                          'Teléfono',
                          style: AppTextStyles(context).small13Bold,
                        ),
                        size: ColumnSize.S,
                        minWidth: 100,
                      ),
                      DataColumn2(
                        label: Text(
                          'Acciones',
                          style: AppTextStyles(context).small14Bold,
                        ),
                        size: ColumnSize.S,
                        minWidth: 120,
                      ),
                    ],
                    source: PatientsDataSource(
                      patients: searchPatientState.patients,
                      context: context,
                      ref: ref,
                    ),
                    availableRowsPerPage: [10],
                    rowsPerPage: searchPatientState.rowsPerPage,
                    onRowsPerPageChanged:
                        (value) => searchPatientNotifier.changeRowsPerPage(
                          value ?? 10,
                        ),
                  ).paddingOnly(top: 20),
                ).expanded(),
            ],
          ),
        ),
      ],
    ).paddingSymmetric(horizontal: 16, vertical: 16);
  }
}
