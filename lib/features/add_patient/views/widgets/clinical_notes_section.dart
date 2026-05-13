import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_provider.dart';
import 'package:oftal_web/features/add_patient/views/widgets/form_section_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ClinicalNotesSection extends ConsumerWidget {
  const ClinicalNotesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(addPatientProvider.notifier);

    return FormSectionCard(
      title: 'Notas clínicas',
      subtitle: 'Opcional · solo personal autorizado',
      icon: Icons.notes_outlined,
      child: ShadInputFormField(
        maxLines: 5,
        controller: notifier.observationsController,
        placeholder: const Text(
          'Antecedentes, observaciones del optómetra, alergias...',
        ),
        keyboardType: TextInputType.multiline,
      ),
    );
  }
}
