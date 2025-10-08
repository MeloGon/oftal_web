import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;
import 'package:oftal_web/shared/services/local_storage.dart';

part 'sell_provider.g.dart';

@riverpod
class Sell extends _$Sell {
  final searchController = TextEditingController();
  final searchItemToSellController = TextEditingController();
  final importController = TextEditingController();
  final discountController = TextEditingController();
  final totalController = TextEditingController();
  final accountController = TextEditingController();
  final restController = TextEditingController();
  @override
  SellState build() {
    return SellState();
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
    state = state.copyWith(
      selectedPatient: patient,
      idRemisionAndFolioSale: _generateRandomId(17).toString(),
    );
  }

  void selectDiscountReason(DiscountReasonEnum discountReason) {
    state = state.copyWith(selectedDiscountReason: discountReason);
  }

  void selectItemOption(SellItemOptionsEnum itemOption) {
    state = state.copyWith(selectedItemOption: itemOption);
  }

  void selectOptionToSell(OptionsToSellEnum option) {
    state = state.copyWith(selectedOptionToSell: option);
  }

  void selectItemToSell(dynamic item) {
    if (state.selectedOptionToSell == OptionsToSellEnum.mount) {
      // state = state.copyWith(mountToSell: item as MountModel);
      final itemParsed = item as MountModel;
      final itemToSell = SalesDetailsModel(
        id:
            _generateRandomId(
              17,
            ).toInt(), //se crea random distinto por cada item a no ser que sean montura y lunas afiliadas
        idRemision:
            state.idRemisionAndFolioSale
                .toString(), //se crea random el mismo para todos los items en una sola compra
        folioSale:
            state.idRemisionAndFolioSale
                .toString(), //se crea random pero es igual para todos los items en una sola compra
        dateSale: DateFormat(
          'dd-MMM-yyyy',
          'es_ES',
        ).format(
          DateTime.now(),
        ), // ver que se cree en formato normal diai-mes-año
        patient: state.selectedPatient?.name,
        idMount: itemParsed.id,
        // mount: itemParsed.model, //acetato, oftalmico, ver como va esto despues
        mountBrand: itemParsed.brand,
        mountModel: itemParsed.model,
        mountColor: itemParsed.color,
        mountQuantity: itemParsed.stock.toString(),
        mountPrice: itemParsed.price,
        mountText: itemParsed.description,
        updatedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
      );
      state = state.copyWith(itemsToSell: [...state.itemsToSell, itemToSell]);
    } else {
      // state = state.copyWith(resinToSell: item as ResinModel);
    }
    importController.text =
        state.itemsToSell
            .fold(
              0.0,
              (previousValue, element) =>
                  previousValue + (element.mountPrice ?? 0),
            )
            .toString();
    discountController.text = '0';
    totalController.text =
        state.itemsToSell
            .fold(
              0.0,
              (previousValue, element) =>
                  previousValue + (element.mountPrice ?? 0),
            )
            .toString();
    accountController.text = '0';
    restController.text =
        state.itemsToSell
            .fold(
              0.0,
              (previousValue, element) =>
                  previousValue + (element.mountPrice ?? 0),
            )
            .toString();
  }

  void applyDiscount() {
    final total =
        double.parse(importController.text) -
        double.parse(discountController.text);
    totalController.text = total.toString();
    restController.text =
        (total - double.parse(accountController.text)).toString();
  }

  void leaveAccount() {
    final total =
        double.parse(importController.text) -
        double.parse(discountController.text);
    restController.text =
        (total - double.parse(accountController.text)).toString();
  }

  Future<void> createSale() async {
    state = state.copyWith(isLoading: true);
    try {
      print('VENTA ${state.itemsToSell[0].folioSale}');

      await Supabase.instance.client
          .from('ventas')
          .insert(state.itemsToSell.map((e) => e.toJson()).toList());
      state = state.copyWith(
        snackbarConfig: SnackbarConfigModel(
          title: 'Venta realizada correctamente',
          type: SnackbarEnum.success,
        ),
      );
      _createShortSale();
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

  Future<void> _createShortSale() async {
    final customerData = await LocalStorage.getProfile();
    state = state.copyWith(isLoading: true);
    try {
      await Supabase.instance.client
          .from('ventas cortas')
          .insert(
            SalesModel(
              id: int.parse(state.itemsToSell[0].idRemision ?? '0'),
              branch: state.selectedPatient?.branch,
              date: DateFormat(
                'dd-MMM-yyyy',
                'es_ES',
              ).format(
                DateTime.now(),
              ),
              updatedDate:
                  DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
              patient: state.selectedPatient?.name,
              authorName: customerData.name,
              total: double.parse(importController.text),
              discount: double.parse(discountController.text),
              totalWithDiscount: double.parse(totalController.text),
              account: double.parse(accountController.text),
              rest: double.parse(restController.text),
              folioSale: state.itemsToSell[0].folioSale,
            ).toJson(),
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

  void cancelSale() {
    state = state.copyWith(
      itemsToSell: [],
      selectedDiscountReason: null,
      selectedItemOption: null,
      selectedOptionToSell: null,
    );
    searchController.text = '';
    searchItemToSellController.text = '';
    importController.text = '0';
    discountController.text = '0';
    totalController.text = '0';
    accountController.text = '0';
    restController.text = '0';
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
