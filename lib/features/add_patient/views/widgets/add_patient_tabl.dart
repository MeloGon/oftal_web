import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddPatientTablet extends ConsumerWidget {
  const AddPatientTablet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addPatientNotifier = ref.watch(addPatientProvider.notifier);
    final addPatientState = ref.watch(addPatientProvider);

    final genderOptions = {
      'Masculino': 'Masculino',
      'Femenino': 'Femenino',
      'Otro': 'Otro',
    };
    final branchOptions = {
      'OFTALVISION': 'OFTALVISION',
      'MEDILENT': 'MEDILENT',
    };

    return Column(
      children: [
        // Primera fila - 2 columnas
        Row(
          children: [
            Expanded(
              child: ShadInputFormField(
                label: Text(AppStrings.identification),
                controller: addPatientNotifier.identificationController,
                // Validaciones específicas para tablet
                // errorText: addPatientState.identificationError,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ShadInputFormField(
                readOnly: true,
                label: Text(AppStrings.uniqueId),
                controller: addPatientNotifier.uniqueIdController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Segunda fila - 2 columnas
        Row(
          children: [
            Expanded(
              child: ShadInputFormField(
                label: Text(AppStrings.registerDate),
                controller: addPatientNotifier.registerDateController,
                readOnly: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.registrationBranch),
                  const SizedBox(height: 8),
                  ShadSelect<String>(
                    placeholder: Text(AppStrings.select),
                    initialValue: addPatientState.selectedBranch,
                    selectedOptionBuilder: (context, value) => Text(value),
                    options:
                        branchOptions.entries
                            .map(
                              (e) => ShadOption(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      addPatientNotifier.updateBranch(value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tercera fila - 2 columnas
        Row(
          children: [
            Expanded(
              flex: 2,
              child: ShadInputFormField(
                label: Text(AppStrings.fullName),
                controller: addPatientNotifier.fullNameController,
                // Validaciones específicas para tablet
                // errorText: addPatientState.fullNameError,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ShadDatePickerFormField(
                height: 36,
                label: Text(AppStrings.birthDate),
                // placeholder: Text(AppStrings.birthDate),
                onChanged: (date) {
                  // Lógica específica para tablet
                  // addPatientNotifier.updateBirthDate(date);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Cuarta fila - 2 columnas
        Row(
          children: [
            Expanded(
              child: ShadInputFormField(
                label: Text(AppStrings.age),
                controller: addPatientNotifier.ageController,
                // Validaciones específicas
                // errorText: addPatientState.ageError,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.gender),
                  const SizedBox(height: 8),
                  ShadSelect<String>(
                    placeholder: Text(AppStrings.select),
                    initialValue: addPatientState.selectedGender,
                    selectedOptionBuilder: (context, value) => Text(value),
                    options:
                        genderOptions.entries
                            .map(
                              (e) => ShadOption(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      addPatientNotifier.updateGender(value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Botones - centrados en tablet
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShadButton.outline(
              child: Text(AppStrings.cancel),
              onPressed: () {
                // Lógica específica para tablet
                // addPatientNotifier.clearForm();
                // Navigator.pop(context);
              },
            ),
            const SizedBox(width: 12),
            ShadButton(
              child:
                  addPatientState.isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(AppStrings.save),
              onPressed:
                  addPatientState.isLoading
                      ? null
                      : () {
                        // Lógica específica para tablet
                        // addPatientNotifier.savePatient();
                      },
            ),
          ],
        ),
      ],
    );
  }
}
