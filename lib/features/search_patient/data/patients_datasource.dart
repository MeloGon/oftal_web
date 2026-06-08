import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/core/theme/app_text_styles.dart';
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
        DataCell(
          PatientActions(
            isForSell: isForSell,
            patient: patient,
            onAddMeasurement: () {
              ref
                  .read(searchPatientProvider.notifier)
                  .openAddViewMeasureDialog(patient.name);
            },
            onViewMeasurements: () {
              ref.read(searchPatientProvider.notifier).getReviews(patient.name);
            },
            onEditPatient: () {
              ref
                  .read(searchPatientProvider.notifier)
                  .openEditDialog(patient);
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
        DataCell(
          Text(patient.name, style: AppTextStyles(context).small12),
        ),
        DataCell(
          Text(patient.registerDate, style: AppTextStyles(context).small12),
        ),
        DataCell(_BranchBadge(branch: patient.branch)),
        DataCell(
          Text(patient.phone, style: AppTextStyles(context).small12),
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

// --- Branch badge ---

class _BranchBadge extends StatelessWidget {
  const _BranchBadge({required this.branch});
  final String branch;

  @override
  Widget build(BuildContext context) {
    final isOftalvision =
        branch.toUpperCase().contains('OFTALVISION');

    final bg = isOftalvision
        ? AppColors.blueBg
        : AppColors.successBgLight;
    final fg = isOftalvision
        ? AppColors.blueDark
        : AppColors.successDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        branch,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
