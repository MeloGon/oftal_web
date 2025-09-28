import 'package:flutter/material.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'sell_provider.g.dart';

@riverpod
class Sell extends _$Sell {
  final searchController = TextEditingController();
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
      state = state.copyWith(
        reviews: response.map((json) => ReviewModel.fromJson(json)).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
