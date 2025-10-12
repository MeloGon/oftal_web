import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_provider.dart';
import 'package:oftal_web/features/search_patient/views/widgets/patient_actions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class PatientsDataSource extends DataTableSource {
  final List<PatientModel> patients;
  final BuildContext context;
  final WidgetRef ref;

  PatientsDataSource({
    required this.patients,
    required this.context,
    required this.ref,
  });

  @override
  DataRow getRow(int index) {
    final patient = patients[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(patient.name)),
        DataCell(Text(patient.registerDate)),
        DataCell(Text(patient.branch)),
        DataCell(Text(patient.phone)),
        DataCell(
          PatientActions(
            patient: patient,
            onAddMeasurement: () {
              ref
                  .read(searchPatientProvider.notifier)
                  .openAddViewMeasureDialog();
            },
            onViewMeasurements: () {
              ref.read(searchPatientProvider.notifier).getReviews(patient.name);
            },
            onDeletePatient: () {
              ref
                  .read(searchPatientProvider.notifier)
                  .deletePatient(patient.id);
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => patients.length;

  @override
  int get selectedRowCount => 0;
}
