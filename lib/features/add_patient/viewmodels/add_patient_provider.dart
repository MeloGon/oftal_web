import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_state.dart';
import 'package:uuid/uuid.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
    return AddPatientState();
  }
}
