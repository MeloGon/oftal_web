import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_provider.dart';
import 'package:oftal_web/features/search_patient/views/widgets/add_review_dialog.dart';
import 'package:oftal_web/features/search_patient/views/widgets/patient_actions.dart';
import 'package:oftal_web/features/search_patient/views/widgets/review_details_dialog.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SearchPatientView extends ConsumerWidget {
  const SearchPatientView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final searchPatientState = ref.watch(searchPatientProvider);
    final searchPatientNotifier = ref.watch(searchPatientProvider.notifier);

    ref.listen(searchPatientProvider, (previous, next) {
      if (next.reviews.isNotEmpty && previous?.reviews != next.reviews) {
        if (context.mounted) {
          ReviewDetailsDialog().show(context, next);
        }
      }
    });

    ref.listen(searchPatientProvider, (previous, next) {
      if (next.isAddViewMeasureDialogOpen &&
          previous?.isAddViewMeasureDialogOpen !=
              next.isAddViewMeasureDialogOpen) {
        if (context.mounted) {
          AddReviewDialog().show(context);
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
                trailing: ShadButton(
                  height: 30,
                  child: Icon(Icons.close),
                ),
              ),
              if (searchPatientState.patients.isNotEmpty)
                DataTable(
                  headingRowHeight: 42,
                  dataRowMinHeight: 40,
                  columns: const [
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Fecha de registro')),
                    DataColumn(label: Text('Sucursal')),
                    DataColumn(label: Text('Teléfono')),
                    DataColumn(label: Text('Acciones')),
                  ],
                  rows:
                      searchPatientState.patients
                          .map(
                            (patient) => DataRow(
                              cells: [
                                DataCell(Text(patient.name)),
                                DataCell(
                                  ShadBadge(child: Text(patient.registerDate)),
                                ),
                                DataCell(Text(patient.branch)),
                                DataCell(Text(patient.phone)),
                                DataCell(
                                  PatientActions(
                                    patient: patient,
                                    onAddMeasurement: () {
                                      searchPatientNotifier
                                          .openAddViewMeasureDialog();
                                    },
                                    onViewMeasurements: () {
                                      ref
                                          .read(searchPatientProvider.notifier)
                                          .getReviews(patient.name);
                                    },
                                    onDeletePatient: () {},
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                ).box(width: width * .9),
            ],
          ),
        ),
      ],
    ).paddingSymmetric(horizontal: 16, vertical: 16);
  }
}
