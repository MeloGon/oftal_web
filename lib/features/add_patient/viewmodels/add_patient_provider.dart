import 'package:flutter/material.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/core/enums/snackbar_enum.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/utils/random_id_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:oftal_web/shared/services/local_storage.dart' as local_storage;

part 'add_patient_provider.g.dart';

@Riverpod(keepAlive: true)
class AddPatient extends _$AddPatient {
  final uniqueIdController = TextEditingController();
  final registerDateController = TextEditingController();
  final registrationBranchController = TextEditingController();
  final nameController = TextEditingController();
  final birthDateController = TextEditingController();
  final phoneController = TextEditingController();
  final observationsController = TextEditingController();

  DateTime selectedBirthDate = DateTime.now();

  @override
  AddPatientState build() {
    uniqueIdController.text = generateRandomId(16).toString();
    registerDateController.text = DateFormat(
      'dd-MMM-yyyy',
      'es_ES',
    ).format(DateTime.now());
    birthDateController.text = DateFormat(
      'dd-MM-yyyy',
    ).format(selectedBirthDate);

    Future.microtask(() {
      initializeBranch();
      _getLastPatients();
    });

    ref.onDispose(() {
      uniqueIdController.dispose();
      registerDateController.dispose();
      registrationBranchController.dispose();
      nameController.dispose();
      birthDateController.dispose();
      phoneController.dispose();
      observationsController.dispose();
    });

    return const AddPatientState();
  }

  Future<void> initializeBranch() async {
    final profile = await local_storage.LocalStorage.getProfile();
    state = state.copyWith(selectedBranch: profile.branchName);
  }

  void updateGender(String? gender) {
    state = state.copyWith(selectedGender: gender);
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

  void updateBirthDate(DateTime date) {
    selectedBirthDate = date;
    birthDateController.text = DateFormat('dd-MM-yyyy').format(date);
  }

  Future<void> createPatient({required bool isValid}) async {
    if (!isValid) return;
    state = state.copyWith(isLoading: true);

    try {
      final extraInfo = observationsController.text.trim();

      final patient = PatientModel(
        id: int.parse(uniqueIdController.text),
        branch: state.selectedBranch?.toUpperCase() ?? '',
        registerDate: registerDateController.text,
        name: nameController.text.toUpperCase(),
        birthDate: birthDateController.text,
        phone: phoneController.text,
        observations: extraInfo.toUpperCase(),
        gender: state.selectedGender ?? '',
        updatedRegisterDate:
            DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
      );

      final result =
          await ref.read(patientRepositoryProvider).insertPatient(patient);
      await result.fold(
        (failure) async => state = state.copyWith(
          errorMessage: failure.message,
          snackbarConfig: SnackbarConfigModel(
            title: 'Error',
            type: SnackbarEnum.error,
          ),
          isLoading: false,
        ),
        (_) async {
          await _getLastPatients();
          clearForm();
          state = state.copyWith(
            errorMessage: 'Paciente creado correctamente',
            snackbarConfig: SnackbarConfigModel(
              title: 'Aviso',
              type: SnackbarEnum.success,
            ),
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
        isLoading: false,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearForm() {
    uniqueIdController.text = generateRandomId(16).toString();
    nameController.clear();
    selectedBirthDate = DateTime.now();
    birthDateController.text = DateFormat(
      'dd-MM-yyyy',
    ).format(selectedBirthDate);
    phoneController.clear();
    observationsController.clear();
    state = state.copyWith(errorMessage: '', selectedGender: null);
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: '', snackbarConfig: null);
  }

  Future<void> _getLastPatients() async {
    state = state.copyWith(isLoading: true);
    final result =
        await ref.read(patientRepositoryProvider).getLastPatients(limit: 5);
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        isLoading: false,
      ),
      (patients) => state = state.copyWith(
        lastPatients: patients,
        isLoading: false,
      ),
    );
  }
}
