import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oftal_web/core/enums/snackbar_enum.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:oftal_web/shared/services/local_storage.dart' as local_storage;
import 'package:supabase_flutter/supabase_flutter.dart';

part 'add_patient_provider.g.dart';

@Riverpod(keepAlive: true)
class AddPatient extends _$AddPatient {
  final identificationController = TextEditingController();
  final uniqueIdController = TextEditingController();
  final registerDateController = TextEditingController();
  final registrationBranchController = TextEditingController();
  final fullNameController = TextEditingController();
  final birthDateController = TextEditingController();
  final genderController = ShadSelectController<String>();
  final phoneController = TextEditingController();
  final observationsController = TextEditingController();

  final mask = MaskTextInputFormatter(
    mask: '##-##-####',
    filter: {
      '#': RegExp(r'[0-9]'),
    },
  );

  @override
  AddPatientState build() {
    uniqueIdController.text = _generateRandomId(17).toString();
    registerDateController.text = DateFormat(
      'dd-MMM-yyyy',
      'es_ES',
    ).format(DateTime.now());

    Future.microtask(() {
      initializeBranch();
    });

    ref.onDispose(() {
      identificationController.dispose();
      uniqueIdController.dispose();
      registerDateController.dispose();
      fullNameController.dispose();
      birthDateController.dispose();
      genderController.dispose();
      phoneController.dispose();
      observationsController.dispose();
    });

    return AddPatientState(formKey: GlobalKey<ShadFormState>());
  }

  BigInt _generateRandomId(int length) {
    final random = Random.secure();
    final buffer = StringBuffer();
    buffer.write(random.nextInt(9) + 1);
    for (int i = 1; i < length; i++) {
      buffer.write(random.nextInt(10));
    }
    return BigInt.parse(buffer.toString());
  }

  Future<void> initializeBranch() async {
    final profile = await local_storage.LocalStorage.getProfile();
    state = state.copyWith(selectedBranch: profile.branchName);
  }

  void updateGender(String? gender) {
    state = state.copyWith(selectedGender: gender);
    genderController.value = {gender ?? ''};
  }

  Future<void> updateBranch(String? branch) async {
    final profile = await local_storage.LocalStorage.getProfile();
    if (profile.role == 'admin') {
      state = state.copyWith(selectedBranch: branch);
    } else {
      state = state.copyWith(
        errorMessage:
            'No tienes permisos para cambiar la sucursal, asi lo intentes no se guardara con la sucursal que seleccionaste',
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      );
    }
  }

  void updateBirthDate(DateTime? birthDate) {
    birthDateController.text =
        DateFormat('yyyy-MM-dd').format(birthDate ?? DateTime.now()).toString();
  }

  Future<void> createPatient() async {
    if (!_validateForm()) return;
    state = state.copyWith(isLoading: true);

    try {
      final patient = PatientModel(
        id: int.parse(uniqueIdController.text),
        branch: state.selectedBranch ?? '',
        registerDate: registerDateController.text,
        name: fullNameController.text,
        birthDate: birthDateController.text,
        phone: phoneController.text,
        observations: observationsController.text,
        gender: state.selectedGender ?? '',
        updatedRegisterDate:
            DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
      );
      await Supabase.instance.client
          .from('pacientes')
          .insert(patient.toJson())
          .select();

      state = state.copyWith(
        errorMessage: 'Paciente creado correctamente',
        snackbarConfig: SnackbarConfigModel(
          title: 'Aviso',
          type: SnackbarEnum.success,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearForm() {
    identificationController.clear();
    fullNameController.clear();
    birthDateController.clear();
    genderController.value.clear();
    state = state.copyWith(
      selectedGender: null,
      selectedBranch: null,
      errorMessage: '',
    );
  }

  bool _validateForm() {
    if (state.formKey?.currentState?.validate() ?? false) {
      return true;
    }
    return false;
  }

  void clearErrorMessage() {
    state = state.copyWith(
      errorMessage: '',
      snackbarConfig: null,
    );
  }
}
