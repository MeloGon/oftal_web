import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/viewmodels/resins/resins_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'resins_provider.g.dart';

@riverpod
class Resins extends _$Resins {
  //controllers for resin
  final descriptionController = TextEditingController();
  final designController = TextEditingController();
  final lineController = TextEditingController();
  final materialController = TextEditingController();
  final technologyController = TextEditingController();
  final priceController = TextEditingController();
  final priceInternalController = TextEditingController();
  final quantityController = TextEditingController();

  @override
  ResinsState build() {
    ref.onDispose(() {
      descriptionController.dispose();
      designController.dispose();
      lineController.dispose();
      materialController.dispose();
      technologyController.dispose();
      priceController.dispose();
      priceInternalController.dispose();
      quantityController.dispose();
    });
    Future.microtask(() async {
      final rowsPerPage = state.rowsPerPage;
      await fetchPage(offset: 0, limit: rowsPerPage);
    });
    return ResinsState();
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

  Future<void> fetchPage({required int offset, required int limit}) async {
    state = state.copyWith(isLoading: true);
    try {
      final end = offset + limit - 1;
      final response = await Supabase.instance.client
          .from('resinas')
          .select()
          .range(offset, end);
      final items = response.map((json) => ResinModel.fromJson(json)).toList();
      final bool hasMore = items.length == limit;
      final int estimatedTotal =
          hasMore ? offset + items.length + limit : offset + items.length;
      state = state.copyWith(
        resins: items,
        offset: offset,
        totalCount: estimatedTotal,
        hasMore: hasMore,
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

  ResinModel _createResin({bool isForEdit = false}) {
    final id = _generateRandomId(17).toInt();
    return ResinModel(
      id: (isForEdit) ? state.selectedResin?.id ?? 0 : id,
      description: descriptionController.text,
      design: designController.text,
      line: lineController.text,
      material: materialController.text,
      technology: technologyController.text,

      text:
          '${descriptionController.text} ${designController.text} ${lineController.text} ${materialController.text} ${technologyController.text}',
      quantity: int.tryParse(quantityController.text) ?? 0,
      price: double.tryParse(priceController.text) ?? 0,
      priceInternal: double.tryParse(priceInternalController.text) ?? 0,
    );
  }

  Future<void> addResin() async {
    state = state.copyWith(isLoading: true);
    try {
      final resin =
          state.selectedResin == null
              ? _createResin()
              : _createResin(isForEdit: true);
      state.selectedResin == null
          ? await Supabase.instance.client
              .from('resinas')
              .insert(
                resin.toJson(),
              )
          : await Supabase.instance.client
              .from('resinas')
              .update(resin.toJson())
              .eq('id_oftalmico', resin.id);
      state = state.copyWith(
        snackbarConfig: SnackbarConfigModel(
          title: 'Aviso',
          type: SnackbarEnum.success,
        ),
        errorMessage:
            state.selectedResin == null
                ? 'Resina creada correctamente'
                : 'Resina actualizada correctamente',
      );
      if (state.selectedResin != null) {
        clearResinSelected();
      }
      clearAddResinForm();
      await fetchPage(offset: state.offset, limit: state.rowsPerPage);
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

  void clearResinSelected() {
    state = ResinsState(
      isLoading: state.isLoading,
      errorMessage: state.errorMessage,
      resins: state.resins,
      rowsPerPage: state.rowsPerPage,
      totalCount: state.totalCount,
      offset: state.offset,
      hasMore: state.hasMore,
      snackbarConfig: state.snackbarConfig,
      isAddResinDialogOpen: state.isAddResinDialogOpen,
      selectedResin: null,
    );
  }

  Future<void> editResin(ResinModel resin) async {
    openAddResinDialog();
    state = state.copyWith(selectedResin: resin);
    descriptionController.text = resin.description ?? '';
    designController.text = resin.design ?? '';
    lineController.text = resin.line ?? '';
    materialController.text = resin.material ?? '';
    technologyController.text = resin.technology ?? '';
    priceController.text = resin.price?.toString() ?? '';
    priceInternalController.text = resin.priceInternal?.toString() ?? '';
    quantityController.text = resin.quantity?.toString() ?? '';
  }

  Future<void> deleteResin(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      await Supabase.instance.client
          .from('resinas')
          .delete()
          .eq('id_oftalmico', id);
      state = state.copyWith(
        snackbarConfig: SnackbarConfigModel(
          title: 'Aviso',
          type: SnackbarEnum.success,
        ),
        errorMessage: 'Resina eliminada correctamente',
      );
      await fetchPage(offset: state.offset, limit: state.rowsPerPage);
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
    priceInternalController.clear();
  }

  void changeRowsPerPage(int newSize) {
    state = state.copyWith(rowsPerPage: newSize);
    fetchPage(offset: 0, limit: newSize);
  }

  void openAddResinDialog() {
    state = state.copyWith(isAddResinDialogOpen: true);
  }

  void closeAddResinDialog() {
    state = state.copyWith(isAddResinDialogOpen: false);
  }

  void clearErrorMessage() {
    state = state.copyWith(
      errorMessage: '',
      snackbarConfig: null,
    );
  }
}
