import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/core/theme/app_text_styles.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_provider.dart';
import 'package:oftal_web/features/add_patient/views/widgets/add_patient_guide.dart';
import 'package:oftal_web/features/add_patient/views/widgets/last_patients_added.dart';
// import 'package:oftal_web/features/sell/views/widgets/invoice_widget.dart';
import 'package:oftal_web/shared/extensions/widget_extension.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:oftal_web/shared/widgets/custom_snackbar.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddPatientView extends ConsumerWidget {
  const AddPatientView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final addPatientNotifier = ref.watch(addPatientProvider.notifier);
    final addPatientState = ref.watch(addPatientProvider);

    final genderOptions = {
      'Masculino': 'Masculino',
      'Femenino': 'Femenino',
      'Otro': 'Otro',
    };

    ref.listen(addPatientProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(
          () => ref.read(addPatientProvider.notifier).clearErrorMessage(),
        );
      }
    });

    return ShadForm(
      key: addPatientState.formKey,
      autovalidateMode: ShadAutovalidateMode.onUserInteraction,
      child: Column(
        spacing: 10,
        children: [
          const AddPatientGuide(),
          ShadCard(
            width: width * .9,
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.identification,
                  style: AppTextStyles(context).small14Bold,
                ),
                Wrap(
                  spacing: 16,
                  runSpacing: 10,
                  direction: Axis.horizontal,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.registrationBranch,
                          style:
                              (ref.read(addPatientProvider).selectedBranch ==
                                      null)
                                  ? AppTextStyles(
                                    context,
                                  ).small12.copyWith(color: Colors.red)
                                  : AppTextStyles(context).small12,
                        ),
                        const SizedBox(height: 8),
                        ShadSelect<BranchEnum>(
                          placeholder: Text(AppStrings.select),
                          initialValue:
                              addPatientState.selectedBranch == null
                                  ? null
                                  : BranchEnum.values.firstWhere(
                                    (e) =>
                                        e.name ==
                                        addPatientState.selectedBranch,
                                  ),
                          selectedOptionBuilder:
                              (context, value) => Text(value.name),
                          options:
                              BranchEnum.values
                                  .map(
                                    (e) => ShadOption(
                                      value: e,
                                      child: Text(e.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            addPatientNotifier.updateBranch(value?.name);
                          },
                        ),
                        if (ref.read(addPatientProvider).selectedBranch == null)
                          Text(
                            AppStrings.lblrequired,
                            style: ShadTheme.of(
                              context,
                            ).textTheme.small.copyWith(color: Colors.red),
                          ).paddingOnly(top: 10),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: width * .3,
                      ),
                      child: ShadInputFormField(
                        readOnly: true,
                        label: Text(
                          AppStrings.uniqueId,
                          style: AppTextStyles(context).small12,
                        ),
                        controller: addPatientNotifier.uniqueIdController,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 118,
                      ),
                      child: ShadInputFormField(
                        label: Text(
                          AppStrings.registerDate,
                          style: AppTextStyles(context).small12,
                        ),
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
            width: width * .9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(
                  AppStrings.patientData,
                  style: AppTextStyles(context).small14Bold,
                ),
                Wrap(
                  spacing: 16,
                  runSpacing: 10,
                  direction: Axis.horizontal,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 300,
                      ),
                      child: ShadInputFormField(
                        label: Text(
                          AppStrings.fullName,
                          style: AppTextStyles(context).small12,
                        ),
                        controller: addPatientNotifier.fullNameController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return AppStrings.lblrequired;
                          }
                          return null;
                        },
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 115,
                      ),
                      child: ShadInputFormField(
                        inputFormatters: [
                          addPatientNotifier.mask,
                        ],
                        placeholder: Text('31-03-2000'),
                        label: Text(
                          AppStrings.birthDate,
                          style: AppTextStyles(context).small12,
                        ),
                        controller: addPatientNotifier.birthDateController,
                        validator:
                            (v) =>
                                RegExp(
                                      r'^(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[0-2])-(19|20)\d{2}$',
                                    ).hasMatch(v)
                                    ? null
                                    : AppStrings.lblrequired,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.gender,
                          style:
                              (ref.read(addPatientProvider).selectedGender ==
                                      null)
                                  ? AppTextStyles(
                                    context,
                                  ).small12.copyWith(color: Colors.red)
                                  : AppTextStyles(context).small12,
                        ),
                        const SizedBox(height: 9),
                        ShadSelect<String>(
                          placeholder: Text(AppStrings.select),
                          initialValue: addPatientState.selectedGender,
                          selectedOptionBuilder:
                              (context, value) => Text(value),
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
                          controller: addPatientNotifier.genderController,
                        ),
                        if (ref.read(addPatientProvider).selectedGender == null)
                          Text(
                            AppStrings.lblrequired,
                            style: ShadTheme.of(
                              context,
                            ).textTheme.small.copyWith(color: Colors.red),
                          ).paddingOnly(top: 10),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 100,
                      ),
                      child: ShadInputFormField(
                        label: Text(
                          'Telefono',
                          style: AppTextStyles(context).small12,
                        ),
                        controller: addPatientNotifier.phoneController,
                        keyboardType: TextInputType.number,
                        // validator: (value) {
                        //   if (value.isEmpty) {
                        //     return AppStrings.lblrequired;
                        //   }
                        //   return null;
                        // },
                      ),
                    ),
                  ],
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 600,
                  ),
                  child: ShadInputFormField(
                    maxLines: 3,
                    label: Text(
                      'Observaciones (Opcional)',
                      style: AppTextStyles(context).small12,
                    ),
                    controller: addPatientNotifier.observationsController,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                // PdfWebExample().box(width: 100, height: 100),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 12,
            children: [
              ShadButton.outline(
                size: ShadButtonSize.lg,
                backgroundColor: Colors.white,
                onPressed: () {
                  ref.read(addPatientProvider.notifier).clearForm();
                },
                child: Text(AppStrings.cancel),
              ),
              ShadButton(
                size: ShadButtonSize.lg,
                onPressed:
                    addPatientState.isLoading
                        ? null
                        : () {
                          addPatientNotifier.createPatient();
                        },
                child: Text(AppStrings.save),
              ),
            ],
          ),
          if (addPatientState.lastPatients.isNotEmpty) LastPatientsAdded(),
        ],
      ).paddingSymmetric(horizontal: 16, vertical: 16),
    );
  }
}

void _showSnackbar(
  BuildContext context,
  SnackbarConfigModel? snackbarConfig,
  String errorMessage,
) {
  CustomSnackbar().show(
    context,
    snackbarConfig ??
        SnackbarConfigModel(title: 'Error', type: SnackbarEnum.error),
    errorMessage,
  );
}
