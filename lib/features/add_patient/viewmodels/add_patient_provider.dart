import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/shared_models.dart';
part 'add_patient_provider.g.dart';

@riverpod
class AddPatient extends _$AddPatient {
  final identificationController = TextEditingController();
  final uniqueIdController = TextEditingController();
  final registerDateController = TextEditingController();
  final registrationBranchController = TextEditingController();
  final fullNameController = TextEditingController();
  final birthDateController = TextEditingController();
  final ageController = TextEditingController();

  @override
  AddPatientState build() {
    uniqueIdController.text = Uuid().v4();
    registerDateController.text = DateFormat(
      'dd-MMM-yyyy',
      'es_ES',
    ).format(DateTime.now());

    Future.microtask(getPatients);

    ref.onDispose(() {
      identificationController.dispose();
      uniqueIdController.dispose();
      registerDateController.dispose();
      fullNameController.dispose();
      birthDateController.dispose();
      ageController.dispose();
    });

    return AddPatientState();
  }

  void updateGender(String? gender) {
    state = state.copyWith(selectedGender: gender);
  }

  void updateBranch(String? branch) {
    state = state.copyWith(selectedBranch: branch);
  }

  Future<void> getPatients() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await Supabase.instance.client
          .from('pacientes')
          .select()
          .limit(8)
          .order('fecha_registro_actualizada', ascending: false);
      state = state.copyWith(
        patients: response.map((json) => PatientModel.fromJson(json)).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearForm() {
    identificationController.clear();
    fullNameController.clear();
    birthDateController.clear();
    ageController.clear();
    state = state.copyWith(
      selectedGender: null,
      selectedBranch: null,
      errorMessage: '',
    );
  }
}
