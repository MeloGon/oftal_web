import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_provider.dart';
import 'package:oftal_web/features/search_patient/views/widgets/patient_actions.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_provider.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class PatientsDataSource extends DataTableSource {
  final List<PatientModel> patients;
  final BuildContext context;
  final WidgetRef ref;
  final bool? isForSell;
  PatientsDataSource({
    required this.patients,
    required this.context,
    required this.ref,
    this.isForSell = false,
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
            isForSell: isForSell,
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
            onSelectPatientToSell:
                (isForSell ?? false)
                    ? () {
                      ref.read(sellProvider.notifier).selectPatient(patient);
                      ref
                          .read(sellProvider.notifier)
                          .selectItemOption(SellItemOptionsEnum.sell);
                    }
                    : null,
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
