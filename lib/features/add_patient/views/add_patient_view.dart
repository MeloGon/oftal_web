import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_provider.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_provider.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/router/router_name.dart';
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
        spacing: 24,
        children: [
          ShadCard(
            width: width * .9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  'Agregar paciente',
                  style: ShadTheme.of(context).textTheme.h2,
                ),
                Text(
                  'En este modulo puedes realizar opciones como:',
                ),
                Text(
                  '\u2022 Agregar un nuevo paciente',
                ),
                Text(
                  '\u2022 Recuerda ingresar todos los campos requeridos, en caso de no hacerlo te indicara cuáles son los campos requeridos',
                ),
                Text(
                  '\u2022 Una vez agregado el paciente te saldra un mensaje de confirmacion',
                ),
                Text(
                  '\u2022 Ya agregado el paciente puedes verlo desde el modulo de buscar paciente',
                ),
                Text(
                  '\u2022 Recuerda aqui solo puedes agregar pacientes, si quieres ver medidas , agregar medidas o eliminar pacientes debes hacerlo desde el modulo de buscar paciente',
                ),
              ],
            ),
          ),
          ShadCard(
            width: width * .9,
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
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.registrationBranch,
                          style:
                              (ref.read(addPatientProvider).selectedBranch ==
                                      null)
                                  ? ShadTheme.of(
                                    context,
                                  ).textTheme.small.copyWith(color: Colors.red)
                                  : ShadTheme.of(context).textTheme.small,
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
                            AppStrings.registrationBranchRequired,
                            style: ShadTheme.of(
                              context,
                            ).textTheme.small.copyWith(color: Colors.red),
                          ).paddingOnly(top: 10),
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
            width: width * .9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  AppStrings.patientData,
                  style: ShadTheme.of(context).textTheme.h4,
                ),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  direction: Axis.horizontal,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * .3,
                      ),
                      child: ShadInputFormField(
                        label: Text(AppStrings.fullName),
                        controller: addPatientNotifier.fullNameController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return AppStrings.fullNameRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * .1,
                      ),
                      child: ShadInputFormField(
                        inputFormatters: [
                          addPatientNotifier.mask,
                        ],
                        placeholder: Text('31-03-2000'),
                        label: Text(AppStrings.birthDate),
                        controller: addPatientNotifier.birthDateController,
                        validator:
                            (v) =>
                                RegExp(
                                      r'^(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[0-2])-(19|20)\d{2}$',
                                    ).hasMatch(v)
                                    ? null
                                    : AppStrings.birthDateRequired,
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
                                  ? ShadTheme.of(
                                    context,
                                  ).textTheme.small.copyWith(color: Colors.red)
                                  : ShadTheme.of(context).textTheme.small,
                        ),
                        const SizedBox(height: 12),
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
                            AppStrings.genderRequired,
                            style: ShadTheme.of(
                              context,
                            ).textTheme.small.copyWith(color: Colors.red),
                          ).paddingOnly(top: 10),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 200,
                      ),
                      child: ShadInputFormField(
                        label: Text('Número de teléfono'),
                        controller: addPatientNotifier.phoneController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return AppStrings.phoneRequired;
                          }
                          return null;
                        },
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
                    label: Text('Observaciones'),
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
                onPressed: () {},
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
          if (addPatientState.lastPatients.isNotEmpty)
            ShadCard(
              width: width * .9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Text(
                    AppStrings.lastPatients,
                    style: ShadTheme.of(context).textTheme.h4,
                  ),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addPatientState.lastPatients.length,
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final patient = addPatientState.lastPatients[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            patient.name,
                          ),
                          InkWell(
                            onTap: () {
                              ref
                                  .read(sellProvider.notifier)
                                  .selectPatientAndOption(
                                    patient,
                                    SellItemOptionsEnum.sell,
                                  );
                              ref.read(appRouterProvider).go(RouterName.sell);
                            },
                            child: Icon(Icons.shopping_bag_rounded),
                          ),
                        ],
                      ).paddingSymmetric(vertical: 2);
                    },
                  ),
                ],
              ),
            ),
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
