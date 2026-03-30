import 'package:flutter/material.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/viewmodels/resins/resins_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/utils/random_id_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'resins_provider.g.dart';

@riverpod
class Resins extends _$Resins {
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
      await fetchPage(offset: 0, limit: state.rowsPerPage);
    });
    return const ResinsState();
  }

  Future<void> fetchPage({required int offset, required int limit}) async {
    state = state.copyWith(isLoading: true);
    final result = await ref
        .read(resinRepositoryProvider)
        .fetchPage(offset: offset, limit: limit);
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        isLoading: false,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (data) {
        final estimatedTotal = data.hasMore
            ? offset + data.items.length + limit
            : offset + data.items.length;
        state = state.copyWith(
          resins: data.items,
          offset: offset,
          totalCount: estimatedTotal,
          hasMore: data.hasMore,
          isLoading: false,
        );
      },
    );
  }

  ResinModel _createResin({bool isForEdit = false}) {
    final id = generateRandomId(17).toInt();
    return ResinModel(
      id: isForEdit ? state.selectedResin?.id ?? 0 : id,
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
      final result = state.selectedResin == null
          ? await ref.read(resinRepositoryProvider).insertResin(resin)
          : await ref.read(resinRepositoryProvider).updateResin(resin);
      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
          snackbarConfig: SnackbarConfigModel(
            title: 'Error',
            type: SnackbarEnum.error,
          ),
        ),
        (_) async {
          state = state.copyWith(
            snackbarConfig: SnackbarConfigModel(
              title: 'Aviso',
              type: SnackbarEnum.success,
            ),
            errorMessage: state.selectedResin == null
                ? 'Resina creada correctamente'
                : 'Resina actualizada correctamente',
          );
          if (state.selectedResin != null) {
            state = state.copyWith(selectedResin: null);
          }
          clearAddResinForm();
          await fetchPage(offset: state.offset, limit: state.rowsPerPage);
        },
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
    final result = await ref.read(resinRepositoryProvider).deleteResin(id);
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        isLoading: false,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (_) async {
        state = state.copyWith(
          snackbarConfig: SnackbarConfigModel(
            title: 'Aviso',
            type: SnackbarEnum.success,
          ),
          errorMessage: 'Resina eliminada correctamente',
        );
        await fetchPage(offset: state.offset, limit: state.rowsPerPage);
      },
    );
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
    state = state.copyWith(errorMessage: '', snackbarConfig: null);
  }
}
