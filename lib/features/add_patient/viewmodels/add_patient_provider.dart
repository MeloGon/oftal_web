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

  // Controladores para ReviewModel
  final reasonConsultController = TextEditingController();
  final clinicHistoryController = TextEditingController();
  final odEsfController = TextEditingController();
  final odCilController = TextEditingController();
  final odEjeController = TextEditingController();
  final odAvController = TextEditingController();
  final oiEsfController = TextEditingController();
  final oiCilController = TextEditingController();
  final oiEjeController = TextEditingController();
  final oiAvController = TextEditingController();
  final addController = TextEditingController();
  final observationReviewController = TextEditingController();
  final dipController = TextEditingController();
  final odCbLcController = TextEditingController();
  final odDiamLcController = TextEditingController();
  final oiCbLcController = TextEditingController();
  final oiDiamLcController = TextEditingController();
  final graduationTypeController = TextEditingController();
  final avSinRxOdLejosController = TextEditingController();
  final avSinRxOiLejosController = TextEditingController();
  final cvOdLejosController = TextEditingController();
  final cvOiLejosController = TextEditingController();
  final avSinRxOdCercaController = TextEditingController();
  final avSinRxOiCercaController = TextEditingController();
  final avConRxOdCercaController = TextEditingController();
  final avConRxOiCercaController = TextEditingController();
  final optometricDiagnosisController = TextEditingController();

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
      _getPatients();
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

      // Dispose de controladores de ReviewModel
      reasonConsultController.dispose();
      clinicHistoryController.dispose();
      odEsfController.dispose();
      odCilController.dispose();
      odEjeController.dispose();
      odAvController.dispose();
      oiEsfController.dispose();
      oiCilController.dispose();
      oiEjeController.dispose();
      oiAvController.dispose();
      addController.dispose();
      observationReviewController.dispose();
      dipController.dispose();
      odCbLcController.dispose();
      odDiamLcController.dispose();
      oiCbLcController.dispose();
      oiDiamLcController.dispose();
      graduationTypeController.dispose();
      avSinRxOdLejosController.dispose();
      avSinRxOiLejosController.dispose();
      cvOdLejosController.dispose();
      cvOiLejosController.dispose();
      avSinRxOdCercaController.dispose();
      avSinRxOiCercaController.dispose();
      avConRxOdCercaController.dispose();
      avConRxOiCercaController.dispose();
      optometricDiagnosisController.dispose();
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

  Future<void> _getPatients() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await Supabase.instance.client
          .from('pacientes')
          .select()
          .limit(5)
          .order('fecha_registro_actualizada', ascending: false);
      state = state.copyWith(
        patients: response.map((json) => PatientModel.fromJson(json)).toList(),
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
      /* final response = */
      await Supabase.instance.client
          .from('pacientes')
          .insert(patient.toJson())
          .select();
      _getPatients();
      state = state.copyWith(
        // patients: response.map((json) => PatientModel.fromJson(json)).toList(),
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

  Future<void> deletePatient(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      await Supabase.instance.client
          .from('pacientes')
          .delete()
          .eq('ID PACIENTE', id);
      state = state.copyWith(
        errorMessage: 'Paciente eliminado correctamente',
        snackbarConfig: SnackbarConfigModel(
          title: 'Aviso',
          type: SnackbarEnum.success,
        ),
      );
      _getPatients();
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

  void openAddViewMeasureDialog(PatientModel patient) {
    state = state.copyWith(
      patientSelected: patient,
      isAddViewMeasureDialogOpen: true,
    );
  }

  Future<void> createReviewModel() async {
    final profile = await local_storage.LocalStorage.getProfile();
    try {
      state = state.copyWith(isLoading: true);

      final review = ReviewModel(
        idReview: _generateRandomId(17).toInt(), // Se asignará desde el backend
        patientName: state.patientSelected?.name,
        date: DateFormat(
          'dd-MMM-yyyy',
          'es_ES',
        ).format(
          DateTime.now(),
        ),
        branchName: profile.branchName,
        reasonConsult:
            reasonConsultController.text.isNotEmpty
                ? reasonConsultController.text
                : null,
        clinicHistory:
            clinicHistoryController.text.isNotEmpty
                ? clinicHistoryController.text
                : null,
        odEsf: odEsfController.text.isNotEmpty ? odEsfController.text : null,
        odCil: odCilController.text.isNotEmpty ? odCilController.text : null,
        odEje: odEjeController.text.isNotEmpty ? odEjeController.text : null,
        odAv: odAvController.text.isNotEmpty ? odAvController.text : null,
        oiEsf: oiEsfController.text.isNotEmpty ? oiEsfController.text : null,
        oiCil: oiCilController.text.isNotEmpty ? oiCilController.text : null,
        oiEje: oiEjeController.text.isNotEmpty ? oiEjeController.text : null,
        oiAv: oiAvController.text.isNotEmpty ? oiAvController.text : null,
        add: addController.text.isNotEmpty ? addController.text : null,
        observation:
            observationReviewController.text.isNotEmpty
                ? observationReviewController.text
                : null,
        dip: dipController.text.isNotEmpty ? dipController.text : null,
        odCbLc: odCbLcController.text.isNotEmpty ? odCbLcController.text : null,
        odDiamLc:
            odDiamLcController.text.isNotEmpty ? odDiamLcController.text : null,
        oiCbLc: oiCbLcController.text.isNotEmpty ? oiCbLcController.text : null,
        oiDiamLc:
            oiDiamLcController.text.isNotEmpty ? oiDiamLcController.text : null,
        graduationType:
            graduationTypeController.text.isNotEmpty
                ? graduationTypeController.text
                : null,
        avSinRxOdLejos:
            avSinRxOdLejosController.text.isNotEmpty
                ? avSinRxOdLejosController.text
                : null,
        avSinRxOiLejos:
            avSinRxOiLejosController.text.isNotEmpty
                ? avSinRxOiLejosController.text
                : null,
        cvOdLejos:
            cvOdLejosController.text.isNotEmpty
                ? cvOdLejosController.text
                : null,
        cvOiLejos:
            cvOiLejosController.text.isNotEmpty
                ? cvOiLejosController.text
                : null,
        avSinRxOdCerca:
            avSinRxOdCercaController.text.isNotEmpty
                ? avSinRxOdCercaController.text
                : null,
        avSinRxOiCerca:
            avSinRxOiCercaController.text.isNotEmpty
                ? avSinRxOiCercaController.text
                : null,
        avConRxOdCerca:
            avConRxOdCercaController.text.isNotEmpty
                ? avConRxOdCercaController.text
                : null,
        avConRxOiCerca:
            avConRxOiCercaController.text.isNotEmpty
                ? avConRxOiCercaController.text
                : null,
        optometricDiagnosis:
            optometricDiagnosisController.text.isNotEmpty
                ? optometricDiagnosisController.text
                : null,
        dateReviewUpdated:
            DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
      );
      await Supabase.instance.client
          .from('revisiones')
          .insert(review.toJson())
          .select();
      _getPatients();
      state = state.copyWith(
        errorMessage: 'Revisión creada correctamente',
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

  void clearReviewForm() {
    reasonConsultController.clear();
    clinicHistoryController.clear();
    odEsfController.clear();
    odCilController.clear();
    odEjeController.clear();
    odAvController.clear();
    oiEsfController.clear();
    oiCilController.clear();
    oiEjeController.clear();
    oiAvController.clear();
    addController.clear();
    observationReviewController.clear();
    dipController.clear();
    odCbLcController.clear();
    odDiamLcController.clear();
    oiCbLcController.clear();
    oiDiamLcController.clear();
    graduationTypeController.clear();
    avSinRxOdLejosController.clear();
    avSinRxOiLejosController.clear();
    cvOdLejosController.clear();
    cvOiLejosController.clear();
    avSinRxOdCercaController.clear();
    avSinRxOiCercaController.clear();
    avConRxOdCercaController.clear();
    avConRxOiCercaController.clear();
    optometricDiagnosisController.clear();
    state = state.copyWith(
      isAddViewMeasureDialogOpen: false,
    );
  }
}
