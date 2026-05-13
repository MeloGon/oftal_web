import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_provider.dart';
import 'package:oftal_web/features/add_patient/views/widgets/form_section_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ContactSection extends ConsumerWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(addPatientProvider.notifier);

    return FormSectionCard(
      title: 'Contacto',
      subtitle: 'Cómo llegar al paciente',
      icon: Icons.phone_outlined,
      child: ShadInputFormField(
        label: const Text('Teléfono *'),
        controller: notifier.phoneController,
        keyboardType: TextInputType.number,
        placeholder: const Text('099-123-4567'),
        leading: const Padding(
          padding: EdgeInsets.only(right: 4),
          child: Icon(
            Icons.circle_outlined,
            size: 12,
            color: Color(0xffA1A1AA),
          ),
        ),
        validator: (v) => v.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }
}
