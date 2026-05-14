import 'package:flutter/material.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/viewmodels/mounts/mounts_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/utils/random_id_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mounts_provider.g.dart';

@riverpod
class Mounts extends _$Mounts {
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final colorController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final optiqueNameController = TextEditingController();
  final barcodeController = TextEditingController();
  final existencesController = TextEditingController();
  final providerController = TextEditingController();
  final searchController = TextEditingController();

  @override
  MountsState build() {
    ref.onDispose(() {
      brandController.dispose();
      modelController.dispose();
      colorController.dispose();
      descriptionController.dispose();
      priceController.dispose();
      optiqueNameController.dispose();
      barcodeController.dispose();
      existencesController.dispose();
      providerController.dispose();
      searchController.dispose();
    });
    Future.microtask(() async {
      await fetchPage(offset: 0, limit: state.rowsPerPage);
    });
    return const MountsState();
  }

  Future<void> fetchPage({required int offset, required int limit}) async {
    state = state.copyWith(isLoading: true);
    final result = await ref
        .read(mountRepositoryProvider)
        .fetchPage(offset: offset, limit: limit);
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
        isLoading: false,
      ),
      (data) {
        final estimatedTotal = data.hasMore
            ? offset + data.items.length + limit
            : offset + data.items.length;
        state = state.copyWith(
          mounts: data.items,
          offset: offset,
          totalCount: estimatedTotal,
          hasMore: data.hasMore,
          isLoading: false,
        );
      },
    );
  }

  void changeRowsPerPage(int newSize) {
    state = state.copyWith(rowsPerPage: newSize);
    fetchPage(offset: 0, limit: newSize);
  }

  Future<void> searchMounts() async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      state = state.copyWith(isSearchMode: false);
      await fetchPage(offset: 0, limit: state.rowsPerPage);
      return;
    }
    state = state.copyWith(isLoading: true, isSearchMode: true);
    final result = await ref.read(mountRepositoryProvider).searchMounts(query);
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
        isLoading: false,
      ),
      (mounts) => state = state.copyWith(
        mounts: mounts,
        totalCount: mounts.length,
        isLoading: false,
      ),
    );
  }

  Future<void> clearSearch() async {
    searchController.clear();
    state = state.copyWith(isSearchMode: false);
    await fetchPage(offset: 0, limit: state.rowsPerPage);
  }

  Future<void> addMount() async {
    state = state.copyWith(isLoading: true);
    try {
      final mount =
          state.selectedMount == null
              ? _createMount()
              : _createMount(isForEdit: true);
      final result = state.selectedMount == null
          ? await ref.read(mountRepositoryProvider).insertMount(mount)
          : await ref.read(mountRepositoryProvider).updateMount(mount);
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
            errorMessage: state.selectedMount == null
                ? 'Montura creada correctamente'
                : 'Montura actualizada correctamente',
          );
          if (state.selectedMount != null) {
            state = state.copyWith(selectedMount: null);
          }
          clearAddMountForm();
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

  void clearAddMountForm() {
    descriptionController.clear();
    modelController.clear();
    brandController.clear();
    existencesController.clear();
    colorController.clear();
    priceController.clear();
    providerController.clear();
    optiqueNameController.clear();
    barcodeController.clear();
  }

  MountModel _createMount({bool isForEdit = false}) {
    final id = generateRandomId(17).toInt();
    return MountModel(
      id: isForEdit ? state.selectedMount?.id ?? 0 : id,
      brand: brandController.text,
      model: modelController.text,
      color: colorController.text,
      description: descriptionController.text,
      price: double.tryParse(priceController.text) ?? 0,
      opticName: optiqueNameController.text,
      barcode: 'codigo barra de prueba',
      stock: int.tryParse(existencesController.text) ?? 0,
    );
  }

  void openAddMountDialog() {
    state = state.copyWith(isAddMountDialogOpen: true);
  }

  void closeAddMountDialog() {
    state = state.copyWith(isAddMountDialogOpen: false);
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: '', snackbarConfig: null);
  }

  Future<void> deleteMount(int id) async {
    state = state.copyWith(isLoading: true);
    final result = await ref.read(mountRepositoryProvider).deleteMount(id);
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
          errorMessage: 'Montura eliminada correctamente',
        );
        await fetchPage(offset: state.offset, limit: state.rowsPerPage);
      },
    );
  }

  Future<void> editMount(MountModel mount) async {
    openAddMountDialog();
    state = state.copyWith(selectedMount: mount);
    brandController.text = mount.brand;
    modelController.text = mount.model;
    colorController.text = mount.color;
    descriptionController.text = mount.description;
    priceController.text = mount.price.toString();
    optiqueNameController.text = mount.opticName;
    barcodeController.text = mount.barcode;
    existencesController.text = mount.stock.toString();
    providerController.text = 'mount';
  }
}
