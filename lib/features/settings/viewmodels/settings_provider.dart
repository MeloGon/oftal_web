import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/viewmodels/settings_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  //controllers for resin
  final descriptionController = TextEditingController();
  final designController = TextEditingController();
  final lineController = TextEditingController();
  final materialController = TextEditingController();
  final technologyController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  @override
  SettingsState build() {
    ref.onDispose(() {
      descriptionController.dispose();
      designController.dispose();
      lineController.dispose();
      materialController.dispose();
      technologyController.dispose();
      priceController.dispose();
      quantityController.dispose();
    });
    return SettingsState();
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

  ResinModel _createResin() {
    final id = _generateRandomId(17).toInt();
    return ResinModel(
      id: id,
      description: descriptionController.text,
      design: designController.text,
      line: lineController.text,
      material: materialController.text,
      technology: technologyController.text,

      text:
          '$descriptionController.text $designController.text $lineController.text $materialController.text $technologyController.text',
      quantity: int.parse(quantityController.text),
      price: double.parse(priceController.text),
    );
  }

  Future<void> addResin() async {
    final resin = _createResin();
    state = state.copyWith(isLoading: true);
    try {
      await Supabase.instance.client
          .from('resinas')
          .insert(
            resin.toJson(),
          );
      state = state.copyWith(
        snackbarConfig: SnackbarConfigModel(
          title: 'Resina creada correctamente',
          type: SnackbarEnum.success,
        ),
      );
      clearAddResinForm();
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

  void clearAddResinForm() {
    descriptionController.clear();
    designController.clear();
    lineController.clear();
    materialController.clear();
    technologyController.clear();
    priceController.clear();
    quantityController.clear();
  }

  void clearErrorMessage() {
    state = state.copyWith(
      errorMessage: '',
      snackbarConfig: null,
    );
  }
}
