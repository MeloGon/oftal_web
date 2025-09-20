import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_provider.dart';
import 'package:oftal_web/shared/extensions/widget_extension.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddPatientDesktop extends ConsumerWidget {
  const AddPatientDesktop({super.key});

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
        ShadCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.identification),
              Row(
                spacing: 16,
                children: [
                  Column(
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
                  ShadInputFormField(
                    readOnly: true,
                    label: Text(AppStrings.uniqueId),
                    controller: addPatientNotifier.uniqueIdController,
                  ).expanded(),
                  ShadInputFormField(
                    label: Text(AppStrings.registerDate),
                    controller: addPatientNotifier.registerDateController,
                    readOnly: true,
                  ).expanded(),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ShadCard(
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.patientData),
              Row(
                spacing: 16,
                children: [
                  ShadInputFormField(
                    label: Text(AppStrings.fullName),
                    controller: addPatientNotifier.fullNameController,
                  ).expanded(flex: 2),
                  ShadDatePickerFormField(
                    height: 36,
                    label: Text(
                      AppStrings.birthDate,
                    ),
                    onChanged: (date) {},
                  ).expanded(),
                  ShadInputFormField(
                    label: Text(AppStrings.age),
                    controller: addPatientNotifier.ageController,
                    keyboardType: TextInputType.number,
                  ).expanded(),
                  Column(
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
                  ).expanded(),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 12,
          children: [
            ShadButton.outline(
              onPressed: () {
                // Lógica específica para desktop
                // addPatientNotifier.clearForm();
                // Navigator.pop(context);
              },
              child: Text(AppStrings.cancel),
            ),
            ShadButton(
              onPressed:
                  addPatientState.isLoading
                      ? null
                      : () {
                        // Lógica específica para desktop
                        // addPatientNotifier.savePatient();
                      },
              child: Text(AppStrings.save),
            ),
          ],
        ),
      ],
    );
  }
}
