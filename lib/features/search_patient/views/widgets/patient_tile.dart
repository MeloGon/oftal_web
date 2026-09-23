import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_provider.dart';
import 'package:oftal_web/features/search_patient/views/widgets/patient_actions.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_provider.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/field_chip.dart';

class PatientTile extends ConsumerWidget {
  const PatientTile({super.key, required this.patient, this.isForSell = false});
  final PatientModel patient;
  final bool isForSell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(searchPatientProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        spacing: 14,
        children: [
          // ─ Ícono ───────────────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),

          // ─ Info ────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Flexible(
                      child: Text(
                        patient.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.zinc900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _BranchBadge(branch: patient.branch),
                  ],
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    FieldChip(label: 'Registro', value: patient.registerDate),
                    if (patient.phone.isNotEmpty)
                      FieldChip(label: 'Teléfono', value: patient.phone),
                  ],
                ),
              ],
            ),
          ),

          // ─ Actions ─────────────────────────────────────
          PatientActions(
            isForSell: isForSell,
            patient: patient,
            onAddMeasurement: () =>
                notifier.openAddViewMeasureDialog(patient.name),
            onViewMeasurements: () => notifier.getReviews(patient.name),
            onEditPatient: () => notifier.openEditDialog(patient),
            onDeletePatient: () => notifier.deletePatient(patient.id),
            onSelectPatientToSell: isForSell
                ? () {
                    ref.read(sellProvider.notifier).selectPatient(patient);
                    ref
                        .read(sellProvider.notifier)
                        .selectItemOption(SellItemOptionsEnum.sell);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _BranchBadge extends StatelessWidget {
  const _BranchBadge({required this.branch});
  final String branch;

  @override
  Widget build(BuildContext context) {
    final isOftalvision = branch.toUpperCase().contains('OFTALVISION');

    final bg = isOftalvision ? AppColors.blueBg : AppColors.successBgLight;
    final fg = isOftalvision ? AppColors.blueDark : AppColors.successDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        branch,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
