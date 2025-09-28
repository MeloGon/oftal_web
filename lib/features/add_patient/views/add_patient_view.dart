import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_provider.dart';
import 'package:oftal_web/shared/extensions/widget_extension.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddPatientView extends ConsumerWidget {
  const AddPatientView({super.key});

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
      spacing: 24,
      children: [
        ShadCard(
          width: MediaQuery.sizeOf(context).width * .9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.identification,
                style: ShadTheme.of(context).textTheme.h4,
              ),
              Wrap(
                spacing: 16,
                direction: Axis.horizontal,
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
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * .3,
                    ),
                    child: ShadInputFormField(
                      readOnly: true,
                      label: Text(AppStrings.uniqueId),
                      controller: addPatientNotifier.uniqueIdController,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * .1,
                    ),
                    child: ShadInputFormField(
                      label: Text(AppStrings.registerDate),
                      controller: addPatientNotifier.registerDateController,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ShadCard(
          width: MediaQuery.sizeOf(context).width * .9,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.patientData,
                style: ShadTheme.of(context).textTheme.h4,
              ),
              Wrap(
                spacing: 16,
                direction: Axis.horizontal,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * .3,
                    ),
                    child: ShadInputFormField(
                      label: Text(AppStrings.fullName),
                      controller: addPatientNotifier.fullNameController,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * .3,
                    ),
                    child: ShadDatePickerFormField(
                      height: 36,
                      label: Text(
                        AppStrings.birthDate,
                      ),
                      onChanged: (date) {},
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 80,
                    ),
                    child: ShadInputFormField(
                      label: Text(AppStrings.age),
                      controller: addPatientNotifier.ageController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
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
                  ),
                ],
              ),
            ],
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 12,
          children: [
            ShadButton.outline(
              backgroundColor: Colors.white,
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
        ShadCard(
          width: MediaQuery.sizeOf(context).width * .9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.lastPatients,
                style: ShadTheme.of(context).textTheme.h4,
              ),
              const SizedBox(height: 16),
              if (addPatientState.isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              if (addPatientState.patients.isNotEmpty)
                Scrollbar(
                  thumbVisibility: true,
                  child: CustomScrollView(
                    shrinkWrap: true,
                    primary: true,
                    slivers: [
                      SliverList.separated(
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final initials =
                              addPatientState.patients[index].name.split(
                                ' ',
                              )[0][0] +
                              addPatientState.patients[index].name.split(
                                ' ',
                              )[1][0];
                          final patient = addPatientState.patients[index];

                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(initials),
                            ),
                            title: Text(patient.name.toUpperCase()),
                            subtitle: Row(
                              children: [
                                Text(
                                  AppStrings.registerDate,
                                  style: ShadTheme.of(context).textTheme.small
                                      .copyWith(fontWeight: FontWeight.w800),
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
                                  icon: Icon(LucideIcons.shoppingBasket300),
                                  onPressed: () {},
                                ),
                                ShadIconButton(
                                  icon: Icon(LucideIcons.trash2300),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: addPatientState.patients.length,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ).paddingSymmetric(horizontal: 16, vertical: 16);
  }
}
