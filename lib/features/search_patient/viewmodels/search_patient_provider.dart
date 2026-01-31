import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/utils/random_id_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'search_patient_provider.g.dart';

@riverpod
class SearchPatient extends _$SearchPatient {
  final searchController = TextEditingController();
  bool get searchIsEmpty => searchController.text.isEmpty;

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
  final dateConsultController = TextEditingController();

  @override
  SearchPatientState build() {
    Future.microtask(getPatients);
    ref.onDispose(() {
      searchController.dispose();
    });
    return SearchPatientState();
  }

  Future<void> getPatients() async {
    state = state.copyWith(isLoading: true);
    try {
      final response =
          searchIsEmpty
              ? await Supabase.instance.client
                  .from('pacientes')
                  .select()
                  .limit(10)
                  .order('fecha_registro_actualizada', ascending: false)
              : await Supabase.instance.client
                  .from('pacientes')
                  .select()
                  .textSearch(
                    '"NOMBRE COMPLETO"',
                    '%${searchController.text}%',
                    type: TextSearchType.plain,
                  );
      state = state.copyWith(
        patients: response.map((json) => PatientModel.fromJson(json)).toList(),
        isLoading: false,
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

  Future<void> getReviews(String patientName) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await Supabase.instance.client
          .from('revisiones')
          .select()
          .ilike('"PACIENTE"', '%$patientName%');
      state = state.copyWith(
        reviews: response.map((json) => ReviewModel.fromJson(json)).toList(),
        isLoading: false,
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

  Future<void> addReview() async {
    final date =
        dateConsultController.text.isEmpty
            ? DateTime.now()
            : DateFormat('dd-MM-yyyy').parse(dateConsultController.text);
    final review = ReviewModel(
      patientName: state.patientName,
      date: DateFormat('dd-MMM-yyyy', 'es_ES').format(date),
      dateReviewUpdated: DateFormat('yyyy-MM-dd').format(date),
      reasonConsult: reasonConsultController.text,
      clinicHistory: clinicHistoryController.text,
      odEsf: odEsfController.text,
      odCil: odCilController.text,
      odEje: odEjeController.text,
      odAv: odAvController.text,
      oiEsf: oiEsfController.text,
      oiCil: oiCilController.text,
      oiEje: oiEjeController.text,
      oiAv: oiAvController.text,
      add: addController.text,
      observation: observationReviewController.text,
      dip: dipController.text,
      idReview: generateRandomId(13).toInt(),
    );
    state = state.copyWith(isLoading: true);
    try {
      await Supabase.instance.client.from('revisiones').insert(review.toJson());
      clearAddReviewForm();
      state = state.copyWith(
        errorMessage: 'Medición agregada correctamente',
        snackbarConfig: SnackbarConfigModel(
          title: 'Aviso',
          type: SnackbarEnum.success,
        ),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  void openAddViewMeasureDialog(String patientName) {
    state = state.copyWith(
      isAddViewMeasureDialogOpen: true,
      patientName: patientName,
    );
  }

  void closeAddViewMeasureDialog() {
    state = state.copyWith(
      isAddViewMeasureDialogOpen: false,
      patientName: '',
    );
  }

  void clearAddReviewForm() {
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
    dateConsultController.clear();
  }

  void changeRowsPerPage(int value) {
    state = state.copyWith(
      rowsPerPage: value,
    );
  }

  Future<void> deletePatient(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      await Supabase.instance.client
          .from('pacientes')
          .delete()
          .eq('ID PACIENTE', id);
      getPatients();
      state = state.copyWith(
        errorMessage: 'Paciente eliminado correctamente',
        snackbarConfig: SnackbarConfigModel(
          title: 'Aviso',
          type: SnackbarEnum.success,
        ),
        isLoading: false,
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

  void clearIsLoading() {
    state = state.copyWith(
      isLoading: false,
    );
  }
}
