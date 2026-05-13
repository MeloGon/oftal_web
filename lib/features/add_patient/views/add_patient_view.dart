import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_provider.dart';
import 'package:oftal_web/features/add_patient/views/widgets/clinical_notes_section.dart';
import 'package:oftal_web/features/add_patient/views/widgets/contact_section.dart';
import 'package:oftal_web/features/add_patient/views/widgets/last_patients_added.dart';
import 'package:oftal_web/features/add_patient/views/widgets/patient_form_header.dart';
import 'package:oftal_web/features/add_patient/views/widgets/patient_summary_sidebar.dart';
import 'package:oftal_web/features/add_patient/views/widgets/personal_data_section.dart';
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
    final notifier = ref.watch(addPatientProvider.notifier);
    final state = ref.watch(addPatientProvider);

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final hPad = constraints.maxWidth < 560 ? 16.0 : 24.0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 24,
                children: [
                  PatientFormHeader(
                    onCancel: notifier.clearForm,
                    onSave: () => notifier.createPatient(
                      isValid: _formKey.currentState?.validate() ?? false,
                    ),
                    isLoading: state.isLoading,
                  ),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 24,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            spacing: 16,
                            children: const [
                              PersonalDataSection(),
                              ContactSection(),
                              ClinicalNotesSection(),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 280,
                          child: PatientSummarySidebar(),
                        ),
                      ],
                    )
                  else
                    const Column(
                      spacing: 16,
                      children: [
                        PersonalDataSection(),
                        ContactSection(),
                        ClinicalNotesSection(),
                        PatientSummarySidebar(),
                      ],
                    ),
                  if (state.lastPatients.isNotEmpty) const LastPatientsAdded(),
                ],
              ),
            );
          },
        ),
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
