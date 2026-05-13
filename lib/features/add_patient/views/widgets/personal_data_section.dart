import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_provider.dart';
import 'package:oftal_web/features/add_patient/views/widgets/form_section_card.dart';
import 'package:oftal_web/features/add_patient/views/widgets/gender_toggle.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PersonalDataSection extends ConsumerStatefulWidget {
  const PersonalDataSection({super.key});

  @override
  ConsumerState<PersonalDataSection> createState() =>
      _PersonalDataSectionState();
}

class _PersonalDataSectionState extends ConsumerState<PersonalDataSection> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(addPatientProvider.notifier);
    final state = ref.watch(addPatientProvider);

    final nameField = ShadInputFormField(
      label: const Text('Nombre completo *'),
      controller: notifier.nameController,
      placeholder: const Text('Ej. María Alejandra González'),
      leading: const Padding(
        padding: EdgeInsets.only(right: 4),
        child: Icon(Icons.person_outline, size: 15, color: Color(0xffA1A1AA)),
      ),
      validator: (v) => v.isEmpty ? 'Campo requerido' : null,
    );

    final idField = _ReadOnlyField(
      label: 'ID',
      controller: notifier.uniqueIdController,
    );

    final registerDateField = _ReadOnlyField(
      label: 'Fecha de registro',
      controller: notifier.registerDateController,
    );

    final birthDateField = AppDatePickerButton(
      label: 'Fecha de nacimiento',
      selectedDate: notifier.selectedBirthDate,
      lastDate: DateTime.now(),
      onDateSelected: (date) {
        notifier.updateBirthDate(date);
        setState(() {});
      },
    );

    final genderToggle = GenderToggle(
      value: state.selectedGender,
      onChanged: (v) => notifier.updateGender(v),
    );

    final branchSelector = _BranchSelector(
      selectedBranch: state.selectedBranch,
      onChanged: (value) => notifier.updateBranch(value?.name),
    );

    return FormSectionCard(
      title: 'Datos personales',
      subtitle: 'Información básica del paciente',
      icon: Icons.person_outline,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 560;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                nameField,
                idField,
                registerDateField,
                birthDateField,
                genderToggle,
                branchSelector,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Expanded(flex: 2, child: nameField),
                  Expanded(child: idField),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Expanded(child: registerDateField),
                  Expanded(child: birthDateField),
                ],
              ),
              genderToggle,
              branchSelector,
            ],
          );
        },
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ShadInputFormField(
      readOnly: true,
      label: Text(label),
      controller: controller,
      style: const TextStyle(color: Color(0xff71717A)),
      trailing: const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(Icons.lock_outline, size: 13, color: Color(0xffC4C4C7)),
      ),
    );
  }
}

class _BranchSelector extends StatelessWidget {
  const _BranchSelector({
    required this.selectedBranch,
    required this.onChanged,
  });

  final String? selectedBranch;
  final ValueChanged<BranchEnum?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            Text(
              'Sucursal de registro',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selectedBranch == null
                    ? Colors.red.shade600
                    : const Color(0xff3F3F46),
              ),
            ),
            Text(
              ' *',
              style: TextStyle(fontSize: 13, color: Colors.red.shade600),
            ),
          ],
        ),
        ShadSelect<BranchEnum>(
          placeholder: const Text('Seleccionar'),
          initialValue: selectedBranch == null
              ? null
              : BranchEnum.values.firstWhere(
                  (e) => e.name == selectedBranch,
                  orElse: () => BranchEnum.values.first,
                ),
          selectedOptionBuilder: (context, value) => Text(value.name),
          options: BranchEnum.values
              .map((e) => ShadOption(value: e, child: Text(e.name)))
              .toList(),
          onChanged: onChanged,
        ),
        if (selectedBranch == null)
          Text(
            'Campo requerido',
            style: TextStyle(fontSize: 11, color: Colors.red.shade600),
          ),
      ],
    );
  }
}
