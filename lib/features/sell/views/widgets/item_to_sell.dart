import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/app_strings.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_provider.dart';
import 'package:oftal_web/shared/models/patient_model.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ItemToSell extends ConsumerWidget {
  const ItemToSell({super.key, required this.patient});
  final PatientModel patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(patient.name),
      subtitle: Row(
        spacing: 10,
        children: [
          Text(AppStrings.registerDate),
          Text(patient.registerDate),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          ShadIconButton(
            icon: Icon(LucideIcons.shoppingBasket300),
            onPressed: () {},
          ),
          ShadIconButton(
            icon: Icon(LucideIcons.eye300),
            onPressed: () async {
              ref.read(sellProvider.notifier).selectPatient(patient);
              ref.read(sellProvider.notifier).getViewMeasurements();
            },
          ),
          ShadIconButton(
            icon: Icon(LucideIcons.trash2300),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
