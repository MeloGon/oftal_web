import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/viewmodels/mounts/mounts_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'mounts_provider.g.dart';

@riverpod
class Mounts extends _$Mounts {
  //controllers for mount
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final colorController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final optiqueNameController = TextEditingController();
  final barcodeController = TextEditingController();
  final existencesController = TextEditingController();
  final providerController = TextEditingController();

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
    });
    Future.microtask(() async {
      final rowsPerPage = state.rowsPerPage;
      await fetchPage(offset: 0, limit: rowsPerPage);
    });
    return MountsState();
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
          .from('armazones')
          .select()
          .range(offset, end);
      final items = response.map((json) => MountModel.fromJson(json)).toList();
      final bool hasMore = items.length == limit;
      final int estimatedTotal =
          hasMore ? offset + items.length + limit : offset + items.length;
      state = state.copyWith(
        mounts: items,
        offset: offset,
        totalCount: estimatedTotal,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void changeRowsPerPage(int newSize) {
    state = state.copyWith(rowsPerPage: newSize);
    fetchPage(offset: 0, limit: newSize);
  }

  Future<void> addMount() async {
    state = state.copyWith(isLoading: true);
    try {
      final mount =
          state.selectedMount == null
              ? _createMount()
              : _createMount(isForEdit: true);
      state.selectedMount == null
          ? await Supabase.instance.client
              .from('armazones')
              .insert(
                mount.toJson(),
              )
          : await Supabase.instance.client
              .from('armazones')
              .update(mount.toJson())
              .eq('ID ARMAZONES', mount.id);
      state = state.copyWith(
        snackbarConfig: SnackbarConfigModel(
          title: 'Aviso',
          type: SnackbarEnum.success,
        ),
        errorMessage:
            state.selectedMount == null
                ? 'Montura creada correctamente'
                : 'Montura actualizada correctamente',
      );
      if (state.selectedMount != null) {
        clearMountSelected();
      }
      clearAddMountForm();
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

  void clearMountSelected() {
    state = MountsState(
      isLoading: state.isLoading,
      errorMessage: state.errorMessage,
      mounts: state.mounts,
      rowsPerPage: state.rowsPerPage,
      totalCount: state.totalCount,
      offset: state.offset,
      hasMore: state.hasMore,
      snackbarConfig: state.snackbarConfig,
      isAddMountDialogOpen: state.isAddMountDialogOpen,
      selectedMount: null,
    );
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
    final id = _generateRandomId(17).toInt();
    return MountModel(
      id: (isForEdit) ? state.selectedMount?.id ?? 0 : id,
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
    state = state.copyWith(
      errorMessage: '',
      snackbarConfig: null,
    );
  }

  Future<void> deleteMount(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      await Supabase.instance.client
          .from('armazones')
          .delete()
          .eq('ID ARMAZON', id);
      state = state.copyWith(
        snackbarConfig: SnackbarConfigModel(
          title: 'Aviso',
          type: SnackbarEnum.success,
        ),
        errorMessage: 'Montura eliminada correctamente',
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
