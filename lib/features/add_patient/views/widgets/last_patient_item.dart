import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_provider.dart';
import 'package:oftal_web/shared/models/patient_model.dart';

class LastPatientItem extends ConsumerWidget {
  const LastPatientItem({
    super.key,
    required this.initials,
    required this.patient,
  });
  final String initials;
  final PatientModel patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(initials),
      ),
      title: Text(patient.name.toUpperCase()),
      subtitle: Row(
        children: [
          Text(
            AppStrings.registerDate,
            style: ShadTheme.of(
              context,
            ).textTheme.small.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            ': ${patient.registerDate}',
          ),
        ],
      ),
      trailing: Row(
        spacing: 10,
        mainAxisSize: MainAxisSize.min,
        children: [
          ShadIconButton(
            icon: Icon(Icons.add_circle_outline_sharp),
            onPressed: () {
              ref
                  .read(addPatientProvider.notifier)
                  .openAddViewMeasureDialog(patient);
            },
          ),
          ShadIconButton(
            icon: Icon(LucideIcons.shoppingBasket300),
            onPressed: () {},
          ),
          ShadIconButton(
            icon: Icon(LucideIcons.trash2300),
            onPressed: () {
              ref.read(addPatientProvider.notifier).deletePatient(patient.id);
            },
          ),
        ],
      ),
    );
  }
}
