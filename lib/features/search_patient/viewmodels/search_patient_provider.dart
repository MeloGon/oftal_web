import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/utils/random_id_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  DateTime selectedConsultDate = DateTime.now();

  void updateConsultDate(DateTime date) {
    selectedConsultDate = date;
    dateConsultController.text = DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  SearchPatientState build() {
    Future.microtask(getPatients);
    ref.onDispose(() {
      searchController.dispose();
    });
    return const SearchPatientState();
  }

  Future<void> getPatients() async {
    state = state.copyWith(isLoading: true);
    final result = searchIsEmpty
        ? await ref
            .read(patientRepositoryProvider)
            .getLastPatients(limit: 10)
        : await ref
            .read(patientRepositoryProvider)
            .searchPatients(searchController.text);
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
        isLoading: false,
      ),
      (patients) => state = state.copyWith(patients: patients, isLoading: false),
    );
  }

  Future<void> getReviews(String patientName) async {
    state = state.copyWith(isLoading: true);
    final result = await ref
        .read(reviewRepositoryProvider)
        .getReviewsByPatient(patientName);
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
        isLoading: false,
      ),
      (reviews) {
        if (reviews.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Este paciente no tiene medidas registradas',
            snackbarConfig: SnackbarConfigModel(
              title: 'Aviso',
              type: SnackbarEnum.info,
            ),
          );
        } else {
          state = state.copyWith(
            reviews: reviews,
            isLoading: false,
            isReviewDialogOpen: true,
          );
        }
      },
    );
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
    final result = await ref.read(reviewRepositoryProvider).insertReview(review);
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        isLoading: false,
      ),
      (_) {
        clearAddReviewForm();
        state = state.copyWith(
          errorMessage: 'Medición agregada correctamente',
          snackbarConfig: SnackbarConfigModel(
            title: 'Aviso',
            type: SnackbarEnum.success,
          ),
          isLoading: false,
        );
      },
    );
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

  void closeReviewDialog() {
    state = state.copyWith(isReviewDialogOpen: false);
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: '', snackbarConfig: null);
  }

  void openEditDialog(PatientModel patient) {
    state = state.copyWith(isEditDialogOpen: true, patientToEdit: patient);
  }

  void closeEditDialog() {
    state = state.copyWith(isEditDialogOpen: false, patientToEdit: null);
  }

  Future<void> updateReview(ReviewModel review) async {
    state = state.copyWith(isLoading: true);
    final result = await ref
        .read(reviewRepositoryProvider)
        .updateReview(review);
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
        isLoading: false,
      ),
      (_) => state = state.copyWith(
        errorMessage: 'Medición actualizada correctamente',
        snackbarConfig: SnackbarConfigModel(
          title: 'Aviso',
          type: SnackbarEnum.success,
        ),
        isLoading: false,
      ),
    );
  }

  Future<void> updatePatient(PatientModel patient) async {
    state = state.copyWith(isLoading: true);
    final result = await ref
        .read(patientRepositoryProvider)
        .updatePatient(patient);
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
        isLoading: false,
      ),
      (_) {
        getPatients();
        state = state.copyWith(
          errorMessage: 'Paciente actualizado correctamente',
          snackbarConfig: SnackbarConfigModel(
            title: 'Aviso',
            type: SnackbarEnum.success,
          ),
          isLoading: false,
        );
      },
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
    state = state.copyWith(rowsPerPage: value);
  }

  Future<void> deletePatient(int id) async {
    state = state.copyWith(isLoading: true);
    final result = await ref.read(patientRepositoryProvider).deletePatient(id);
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
        isLoading: false,
      ),
      (_) {
        getPatients();
        state = state.copyWith(
          errorMessage: 'Paciente eliminado correctamente',
          snackbarConfig: SnackbarConfigModel(
            title: 'Aviso',
            type: SnackbarEnum.success,
          ),
          isLoading: false,
        );
      },
    );
  }

  void clearIsLoading() {
    state = state.copyWith(isLoading: false);
  }
}
