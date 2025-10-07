import 'package:flutter/material.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'sell_provider.g.dart';

@riverpod
class Sell extends _$Sell {
  final searchController = TextEditingController();
  final searchItemToSellController = TextEditingController();
  @override
  SellState build() {
    return SellState();
  }

  Future<void> searchPatient() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await Supabase.instance.client
          .from('pacientes')
          .select()
          .textSearch(
            '"NOMBRE COMPLETO"',
            '%${searchController.text}%',
            type: TextSearchType.plain,
          );

      state = state.copyWith(
        patients: response.map((json) => PatientModel.fromJson(json)).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
        patients: [],
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectPatient(PatientModel patient) {
    state = state.copyWith(selectedPatient: patient);
  }

  Future<void> getViewMeasurements() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await Supabase.instance.client
          .from('revisiones')
          .select()
          .ilike(
            '"PACIENTE"',
            '%${state.selectedPatient?.name ?? ''}%',
          );
      print(response);
      state = state.copyWith(
        reviews: response.map((json) => ReviewModel.fromJson(json)).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> getMounts() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await Supabase.instance.client
          .from('armazones')
          .select()
          .textSearch(
            '"MARCA"',
            '%${searchItemToSellController.text}%',
            type: TextSearchType.plain,
          );
      state = state.copyWith(
        mounts: response.map((json) => MountModel.fromJson(json)).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
