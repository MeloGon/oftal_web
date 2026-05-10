import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_provider.dart';
import 'package:oftal_web/features/add_patient/views/widgets/last_patients_added.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddPatientView extends ConsumerStatefulWidget {
  const AddPatientView({super.key});

  @override
  ConsumerState<AddPatientView> createState() => _AddPatientViewState();
}

class _AddPatientViewState extends ConsumerState<AddPatientView> {
  final _formKey = GlobalKey<ShadFormState>();

  @override
  Widget build(BuildContext context) {
    final addPatientNotifier = ref.watch(addPatientProvider.notifier);
    final addPatientState = ref.watch(addPatientProvider);

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
      key: _formKey,
      autovalidateMode: ShadAutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            // ─── Page header ───────────────────────────────
            const _PageHeader(),

            // ─── Identification card ───────────────────────
            _SectionCard(
              title: AppStrings.identification,
              icon: Icons.badge_outlined,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 520;

                  final branchField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Row(
                        spacing: 2,
                        children: [
                          Text(
                            AppStrings.registrationBranch,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color:
                                  addPatientState.selectedBranch == null
                                      ? Colors.red.shade600
                                      : const Color(0xff3F3F46),
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                      ShadSelect<BranchEnum>(
                        placeholder: Text(AppStrings.select),
                        initialValue:
                            addPatientState.selectedBranch == null
                                ? null
                                : BranchEnum.values.firstWhere(
                                  (e) =>
                                      e.name == addPatientState.selectedBranch,
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
                        onChanged:
                            (value) =>
                                addPatientNotifier.updateBranch(value?.name),
                      ),
                      if (addPatientState.selectedBranch == null)
                        Text(
                          AppStrings.lblrequired,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade600,
                          ),
                        ),
                    ],
                  );

                  final idField = ShadInputFormField(
                    readOnly: true,
                    label: Text(AppStrings.uniqueId),
                    controller: addPatientNotifier.uniqueIdController,
                  );

                  final dateField = ShadInputFormField(
                    readOnly: true,
                    label: Text(AppStrings.registerDate),
                    controller: addPatientNotifier.registerDateController,
                  );

                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        SizedBox(width: 200, child: branchField),
                        Expanded(child: idField),
                        SizedBox(width: 140, child: dateField),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [branchField, idField, dateField],
                  );
                },
              ),
            ),

            // ─── Patient data card ─────────────────────────
            _SectionCard(
              title: AppStrings.patientData,
              icon: Icons.person_outline,
              child: Column(
                spacing: 16,
                children: [
                  // Row 1: name | birth date | gender | phone
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 520;

                      final nameField = ShadInputFormField(
                        label: Text(AppStrings.fullName),
                        controller: addPatientNotifier.fullNameController,
                        validator: (value) {
                          if (value.isEmpty) return AppStrings.lblrequired;
                          return null;
                        },
                      );

                      final birthField = AppDatePickerButton(
                        label: AppStrings.birthDate,
                        selectedDate: addPatientNotifier.selectedBirthDate,
                        lastDate: DateTime.now(),
                        onDateSelected: (date) {
                          addPatientNotifier.updateBirthDate(date);
                          setState(() {});
                        },
                      );

                      final genderField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [
                          Row(
                            spacing: 2,
                            children: [
                              Text(
                                AppStrings.gender,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      addPatientState.selectedGender == null
                                          ? Colors.red.shade600
                                          : const Color(0xff3F3F46),
                                ),
                              ),
                              Text(
                                ' *',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.red.shade600,
                                ),
                              ),
                            ],
                          ),
                          ShadSelect<String>(
                            placeholder: Text(AppStrings.select),
                            initialValue: addPatientState.selectedGender,
                            selectedOptionBuilder:
                                (context, value) => Text(value),
                            options:
                                const ['Masculino', 'Femenino', 'Otro']
                                    .map(
                                      (e) =>
                                          ShadOption(value: e, child: Text(e)),
                                    )
                                    .toList(),
                            onChanged: addPatientNotifier.updateGender,
                            controller: addPatientNotifier.genderController,
                          ),
                          if (addPatientState.selectedGender == null)
                            Text(
                              AppStrings.lblrequired,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red.shade600,
                              ),
                            ),
                        ],
                      );

                      final phoneField = ShadInputFormField(
                        label: const Text('Teléfono'),
                        controller: addPatientNotifier.phoneController,
                        keyboardType: TextInputType.number,
                      );

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16,
                          children: [
                            Expanded(flex: 3, child: nameField),
                            SizedBox(width: 140, child: birthField),
                            SizedBox(width: 160, child: genderField),
                            SizedBox(width: 130, child: phoneField),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          nameField,
                          Row(
                            spacing: 16,
                            children: [
                              Expanded(child: birthField),
                              Expanded(child: genderField),
                            ],
                          ),
                          phoneField,
                        ],
                      );
                    },
                  ),
                  // Row 2: observations full width
                  ShadInputFormField(
                    maxLines: 3,
                    label: const Text('Observaciones (Opcional)'),
                    controller: addPatientNotifier.observationsController,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),

            // ─── Actions ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 12,
              children: [
                ShadButton.outline(
                  size: ShadButtonSize.lg,
                  onPressed:
                      () => ref.read(addPatientProvider.notifier).clearForm(),
                  child: Text(AppStrings.cancel),
                ),
                ShadButton(
                  size: ShadButtonSize.lg,
                  onPressed:
                      addPatientState.isLoading
                          ? null
                          : () => addPatientNotifier.createPatient(
                            isValid: _formKey.currentState?.validate() ?? false,
                          ),
                  child:
                      addPatientState.isLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(AppStrings.save),
                ),
              ],
            ),

            // ─── Last patients ─────────────────────────────
            if (addPatientState.lastPatients.isNotEmpty)
              const LastPatientsAdded(),
          ],
        ),
      ),
      ),
    );
  }
}

// ─── Local widgets ──────────────────────────────────────────────────────────

class _PageHeader extends StatefulWidget {
  const _PageHeader();

  @override
  State<_PageHeader> createState() => _PageHeaderState();
}

class _PageHeaderState extends State<_PageHeader> {
  final _popoverController = ShadPopoverController();

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            const Text(
              'Agregar Paciente',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xff18181B),
              ),
            ),
            Text(
              'Registra un nuevo paciente en el sistema',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
        ShadPopover(
          controller: _popoverController,
          popover: (context) => IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                const Text(
                  'Instrucciones',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff18181B),
                  ),
                ),
                const Divider(height: 1),
                ...[
                  'Ingresa todos los campos requeridos. El sistema te indicará cuáles faltan.',
                  'Una vez guardado, recibirás un mensaje de confirmación.',
                  'Puedes ver el paciente desde el módulo "Buscar paciente" o en la lista de últimos 7 clientes al final de esta página.',
                  'Para agregar medidas, ver historial o eliminar pacientes, usa el módulo "Buscar paciente".',
                ].map(
                  (text) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Icon(
                          Icons.circle,
                          size: 5,
                          color: Color(0xff7A6BF5),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff52525B),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          child: ShadButton.ghost(
            padding: const EdgeInsets.all(6),
            onPressed: _popoverController.toggle,
            child: const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: Color(0xff7A6BF5),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            spacing: 8,
            children: [
              Icon(icon, size: 16, color: const Color(0xff7A6BF5)),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff18181B),
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          child,
        ],
      ),
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
