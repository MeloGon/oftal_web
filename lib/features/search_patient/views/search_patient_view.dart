import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/datatables/datatables.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_provider.dart';
import 'package:oftal_web/features/search_patient/views/widgets/add_review_dialog.dart';
import 'package:oftal_web/features/search_patient/views/widgets/review_details_dialog.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/widgets/loading_dialog.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SearchPatientView extends ConsumerWidget {
  const SearchPatientView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(
                'Buscar paciente',
                style: ShadTheme.of(context).textTheme.h2,
              ),
              Text(
                'En este modulo puedes realizar opciones como:',
              ),
              Text(
                '\u2022 Buscar un paciente por su nombre completo o un aproximado',
              ),
              Text('\u2022 Ver las mediciones de un paciente'),
              Text('\u2022 Agregar mediciones a un paciente'),
              Text('\u2022 Eliminar un paciente (solo si eres admin)'),
              Text('\u2022 Actualizar un paciente'),
            ],
          ),
        ),
        ShadCard(
          width: width * .9,
          child: Column(
            children: [
              ShadInputFormField(
                placeholder: Text('Ingrese el nombre del paciente'),
                controller: searchPatientNotifier.searchController,
                leading: Icon(LucideIcons.search),
                onSubmitted: (_) => searchPatientNotifier.getPatients(),
                trailing:
                    searchPatientNotifier.searchIsEmpty
                        ? null
                        : ShadButton(
                          onPressed: () {
                            searchPatientNotifier.searchController.clear();
                            searchPatientNotifier.getPatients();
                          },
                          height: 30,
                          child: Icon(Icons.close),
                        ),
              ),
              if (searchPatientState.patients.isNotEmpty)
                SizedBox(
                  width: width * .9,
                  height: 600,
                  child: PaginatedDataTable2(
                    wrapInCard: false,
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: width * .9,
                    isHorizontalScrollBarVisible: true,
                    isVerticalScrollBarVisible: true,
                    headingRowHeight: 42,
                    columns: const [
                      DataColumn2(label: Text('Nombre')),
                      DataColumn2(label: Text('Fecha de registro')),
                      DataColumn2(label: Text('Sucursal')),
                      DataColumn2(label: Text('Teléfono')),
                      DataColumn2(label: Text('Acciones')),
                    ],
                    source: PatientsDataSource(
                      patients: searchPatientState.patients,
                      context: context,
                      ref: ref,
                    ),
                    availableRowsPerPage: [7, 10, 15, 20],
                    rowsPerPage: searchPatientState.rowsPerPage,
                    onRowsPerPageChanged:
                        (value) =>
                            searchPatientNotifier.changeRowsPerPage(value ?? 7),
                  ),
                ).paddingOnly(top: 20),
            ],
          ),
        ),
      ],
    ).paddingSymmetric(horizontal: 16, vertical: 16);
  }
}
