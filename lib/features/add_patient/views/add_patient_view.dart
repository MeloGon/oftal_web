import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_provider.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddPatientView extends ConsumerWidget {
  const AddPatientView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addPatientNotifier = ref.watch(addPatientProvider.notifier);
    final genderOptions = {
      'Masculino': 'Masculino',
      'Femenino': 'Femenino',
      'Otro': 'Otro',
    };
    final branchOptions = {
      'OFTALVISION': 'OFTALVISION',
      'MEDILENT': 'MEDILENT',
    };
    return SizedBox(
      child: ShadCard(
        child: ListView(
          shrinkWrap: true,
          children: [
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: ShadInputFormField(
                    label: Text(AppStrings.identification),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: ShadInputFormField(
                    readOnly: true,
                    label: Text(AppStrings.uniqueId),
                    controller: addPatientNotifier.uniqueIdController,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: ShadInputFormField(
                    label: Text(AppStrings.registerDate),
                    controller: addPatientNotifier.registerDateController,
                    readOnly: true,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 7.5,
                    children: [
                      Text(AppStrings.registrationBranch),
                      ShadSelect<String>(
                        placeholder: Text(AppStrings.select),
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
                      ),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 360),
                  child: ShadInputFormField(
                    label: Text(AppStrings.fullName),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: ShadDatePickerFormField(
                    height: 36,
                    label: Text(AppStrings.birthDate),
                    placeholder: Text(AppStrings.birthDate),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 80),
                  child: ShadInputFormField(
                    label: Text(AppStrings.age),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 7.5,
                    children: [
                      Text(AppStrings.gender),
                      ShadSelect<String>(
                        placeholder: Text(AppStrings.select),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ShadButton(
              child: Text(AppStrings.save),
              onPressed: () {},
            ),
          ],
        ),
      ),
    ).marginOnly(top: 50).paddingSymmetric(horizontal: 20);
  }
}
