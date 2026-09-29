import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_form_controllers.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/utils/random_id_generator.dart';
import 'package:oftal_web/shared/services/receipt_pdf_service.dart';

part 'sell_provider.g.dart';

@Riverpod(keepAlive: true)
class Sell extends _$Sell {
  late final SellFormControllers _form;

  TextEditingController get searchController => _form.search;
  TextEditingController get searchItemToSellController => _form.searchItemToSell;
  TextEditingController get importController => _form.import_;
  TextEditingController get discountController => _form.discount;
  TextEditingController get totalController => _form.total;
  TextEditingController get accountController => _form.account;
  TextEditingController get restController => _form.rest;
  TextEditingController get dateController => _form.date;
  DateTime get selectedDate => _form.selectedDate;

  @override
  SellState build() {
    _form = SellFormControllers();
    ref.onDispose(_form.dispose);
    return SellState(selectedBranch: _defaultBranch);
  }

  BranchEnum get _defaultBranch {
    final branchName = ref.read(authProvider).profile?.branchName ?? '';
    return BranchEnum.values.firstWhere(
      (e) => e.name == branchName,
      orElse: () => BranchEnum.oftalvision,
    );
  }

  void updateDate(DateTime date) {
    _form.updateDate(date);
  }

  void resetState() {
    _form.clearAll();
    state = const SellState();
    state = state.copyWith(
      selectedInitialPaymentMethod: null,
      selectedBranch: _defaultBranch,
    );
  }

  Future<void> searchPatient() async {
    state = state.copyWith(isLoading: true);
    final result = await ref
        .read(patientRepositoryProvider)
        .searchPatients(searchController.text);
    result.fold(
      (failure) =>
          state = state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            patients: [],
            snackbarConfig: SnackbarConfigModel(
              title: 'Error',
              type: SnackbarEnum.error,
            ),
          ),
      (patients) =>
          state = state.copyWith(patients: patients, isLoading: false),
    );
  }

  Future<void> selectPatient(PatientModel patient) async {
    await _getSellers();
    state = state.copyWith(
      selectedPatient: patient,
      idRemision: generateRandomId(17).toString(),
      idFolio: generateRandomId(6).toString(),
    );
  }

  Future<void> selectPatientAndOption(
    PatientModel patient,
    SellItemOptionsEnum itemOption,
  ) async {
    await _getSellers();
    state = state.copyWith(
      selectedPatient: patient,
      selectedItemOption: itemOption,
      idRemision: generateRandomId(17).toString(),
      idFolio: generateRandomId(6).toString(),
    );
  }

  void selectInitialPaymentMethod(PaymentMethodEnum? method) {
    state = state.copyWith(selectedInitialPaymentMethod: method);
  }

  void selectDiscountReason(DiscountReasonEnum discountReason) {
    state = state.copyWith(selectedDiscountReason: discountReason);
  }

  void selectItemOption(SellItemOptionsEnum itemOption) {
    state = state.copyWith(selectedItemOption: itemOption);
  }

  void selectOptionToSell(OptionsToSellEnum option) {
    state = state.copyWith(selectedOptionToSell: option);
    clearProductsToChoose(option);
  }

  void clearProductsToChoose(OptionsToSellEnum option) {
    switch (option) {
      case OptionsToSellEnum.mount:
        state = state.copyWith(resins: []);
        break;
      case OptionsToSellEnum.resin:
        state = state.copyWith(mounts: []);
        break;
      case OptionsToSellEnum.others:
        break;
    }
  }

  void selectItemToSell(dynamic item) {
    if (state.selectedOptionToSell == OptionsToSellEnum.mount) {
      final itemParsed = item as MountModel;
      final itemToSell = SalesDetailsModel(
        id: generateRandomId(17).toInt(),
        idRemision: state.idRemision.toString(),
        folioSale: state.idFolio.toString(),
        idOftalmico: itemParsed.id,
        dateSale:
            DateFormat('dd-MMM-yy')
                .format(DateFormat('dd-MM-yyyy').parse(dateController.text))
                .toString(),
        patient: state.selectedPatient?.name,
        idMount: itemParsed.id,
        mountBrand: itemParsed.brand,
        mountModel: itemParsed.model,
        mountColor: itemParsed.color,
        mountQuantity: itemParsed.stock.toString(),
        mountPrice: itemParsed.price,
        mountText: itemParsed.description,
        updatedDate:
            DateFormat('yyyy-MM-dd')
                .format(DateFormat('dd-MM-yyyy').parse(dateController.text))
                .toString(),
      );
      state = state.copyWith(itemsToSell: [...state.itemsToSell, itemToSell]);
    } else {
      final itemParsed = item as ResinModel;
      final itemToSell = SalesDetailsModel(
        id: generateRandomId(17).toInt(),
        idRemision: state.idRemision.toString(),
        folioSale: state.idFolio.toString(),
        description: itemParsed.description,
        design: itemParsed.design,
        line: itemParsed.line,
        material: itemParsed.material,
        technology: itemParsed.technology,
        patient: state.selectedPatient?.name,
        dateSale:
            DateFormat('dd-MMM-yy')
                .format(DateFormat('dd-MM-yyyy').parse(dateController.text))
                .toString(),
        text: itemParsed.text,
        quantity: itemParsed.quantity.toString(),
        price: itemParsed.price,
        updatedDate:
            DateFormat('yyyy-MM-dd')
                .format(DateFormat('dd-MM-yyyy').parse(dateController.text))
                .toString(),
      );
      state = state.copyWith(itemsToSell: [...state.itemsToSell, itemToSell]);
    }
    _recalculateTotals();
    state = state.copyWith(
      snackbarConfig: SnackbarConfigModel(
        title: 'Aviso',
        type: SnackbarEnum.success,
      ),
      errorMessage: 'Item añadido correctamente',
    );
  }

  void _recalculateTotals() {
    final total = state.itemsToSell.fold(
      0.0,
      (prev, e) => prev + (e.mountPrice ?? e.price ?? 0.0),
    );
    importController.text = total.toString();
    discountController.text = '0';
    totalController.text = total.toString();
    accountController.text = '0';
    restController.text = total.toString();
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
    if (state.selectedSeller == null) {
      state = state.copyWith(
        errorMessage: 'Debes seleccionar un vendedor antes de crear la venta',
        snackbarConfig: SnackbarConfigModel(
          title: 'Aviso',
          type: SnackbarEnum.error,
        ),
      );
      return;
    }
    if (state.selectedBranch == null) {
      state = state.copyWith(
        errorMessage: 'Debes seleccionar una sucursal antes de crear la venta',
        snackbarConfig: SnackbarConfigModel(
          title: 'Aviso',
          type: SnackbarEnum.error,
        ),
      );
      return;
    }
    state = state.copyWith(isLoading: true);
    _checkDate();
    try {
      //print('VENTA ${state.itemsToSell[0].folioSale}');
      await _deleteItemsInDatabase();
      final insertResult = await ref
          .read(saleRepositoryProvider)
          .insertSalesDetails(state.itemsToSell);
      insertResult.fold(
        (failure) =>
            state = state.copyWith(
              errorMessage: failure.message,
              snackbarConfig: SnackbarConfigModel(
                title: 'Error',
                type: SnackbarEnum.error,
              ),
              isLoading: false,
            ),
        (_) => _createShortSale(),
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

  Future<void> _deleteItemsInDatabase() async {
    for (var item in state.itemsToSell) {
      if (item.idOftalmico != null && item.idOftalmico != 0) {
        final mountResult = await ref
            .read(mountRepositoryProvider)
            .getMountById(item.idOftalmico!);
        await mountResult.fold(
          (failure) async {},
          (mount) async {
            await ref
                .read(mountRepositoryProvider)
                .decrementStock(mount.id, mount.stock);
          },
        );
      }
    }
  }

  void _checkDate() {
    final updatedDate =
        state.itemsToSell
            .map(
              (item) => item.copyWith(
                updatedDate:
                    DateFormat('yyyy-MM-dd')
                        .format(
                          DateFormat('dd-MM-yyyy').parse(dateController.text),
                        )
                        .toString(),
                dateSale:
                    DateFormat('dd-MMM-yy')
                        .format(
                          DateFormat('dd-MM-yyyy').parse(dateController.text),
                        )
                        .toString(),
              ),
            )
            .toList();
    state = state.copyWith(itemsToSell: updatedDate);
  }

  Future<void> _createShortSale() async {
    try {
      final sale = SalesModel(
        id: state.idRemision,
        branch: state.selectedBranch?.name,
        date:
            DateFormat('dd-MMM-yy')
                .format(
                  DateFormat('dd-MM-yyyy').parse(dateController.text),
                )
                .toString(),
        updatedDate:
            DateFormat('yyyy-MM-dd')
                .format(
                  DateFormat('dd-MM-yyyy').parse(dateController.text),
                )
                .toString(),
        fechaVentaIso:
            DateFormat('yyyy-MM-dd')
                .format(
                  DateFormat('dd-MM-yyyy').parse(dateController.text),
                )
                .toString(),
        patient: state.selectedPatient?.name,
        authorName: state.selectedSeller?.name ?? '',
        total: double.parse(importController.text),
        discount: double.parse(discountController.text),
        totalWithDiscount: double.parse(totalController.text),
        account: double.parse(accountController.text),
        rest: double.parse(restController.text),
        folioSale: state.itemsToSell[0].folioSale,
      );
      final result = await ref
          .read(saleRepositoryProvider)
          .insertShortSale(sale);
      result.fold(
        (failure) =>
            state = state.copyWith(
              errorMessage: failure.message,
              snackbarConfig: SnackbarConfigModel(
                title: 'Error',
                type: SnackbarEnum.error,
              ),
              isLoading: false,
            ),
        (_) async {
          final account = double.tryParse(accountController.text) ?? 0;
          if (account > 0 && state.idRemision.isNotEmpty) {
            final saleDate = DateFormat(
              'yyyy-MM-dd',
            ).format(DateFormat('dd-MM-yyyy').parse(dateController.text));
            final userId = ref.read(authProvider).profile?.id;
            final initialPayment = PaymentModel(
              idRemision: state.idRemision,
              monto: account,
              fechaPago: saleDate,
              metodoPago: state.selectedInitialPaymentMethod?.value ?? 'otro',
              registradoPor: userId,
              notas: 'Pago inicial de venta',
              paymentType: 'nueva_venta',
            );
            await ref
                .read(paymentRepositoryProvider)
                .insertPayment(initialPayment);
          }
          // Capture before reset so PDF has all data
          final details = List<SalesDetailsModel>.from(state.itemsToSell);
          state = state.copyWith(
            isLoading: false,
            snackbarConfig: SnackbarConfigModel(
              title: 'Aviso',
              type: SnackbarEnum.success,
            ),
            errorMessage: 'Venta realizada correctamente',
          );
          Future.microtask(resetState);
          await _generatePdf(sale, details);
        },
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

  void cancelSale() {
    state = state.copyWith(
      selectedPatient: null,
      patients: [],
      itemsToSell: [],
      selectedDiscountReason: null,
      selectedItemOption: null,
      selectedOptionToSell: null,
      selectedInitialPaymentMethod: null,
    );
    _form.search.clear();
    _form.searchItemToSell.clear();
    _form.resetTotals();
  }

  Future<void> getViewMeasurements() async {
    state = state.copyWith(isLoading: true);
    final result = await ref
        .read(reviewRepositoryProvider)
        .getReviewsByPatient(state.selectedPatient?.name ?? '');
    result.fold(
      (failure) =>
          state = state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            snackbarConfig: SnackbarConfigModel(
              title: 'Error',
              type: SnackbarEnum.error,
            ),
          ),
      (reviews) {
        if (reviews.isNotEmpty) {
          state = state.copyWith(reviews: reviews, isLoading: false);
        } else {
          state = state.copyWith(
            errorMessage: 'No se encontraron mediciones',
            isLoading: false,
            snackbarConfig: SnackbarConfigModel(
              title: 'Aviso',
              type: SnackbarEnum.error,
            ),
          );
        }
      },
    );
  }

  Future<void> getMounts() async {
    state = state.copyWith(isLoading: true);
    final result = await ref
        .read(mountRepositoryProvider)
        .searchMounts(searchItemToSellController.text);
    result.fold(
      (failure) =>
          state = state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            snackbarConfig: SnackbarConfigModel(
              title: 'Error',
              type: SnackbarEnum.error,
            ),
          ),
      (mounts) =>
          state = state.copyWith(
            mounts: mounts.where((m) => m.stock > 0).toList(),
            isLoading: false,
          ),
    );
  }

  Future<void> getResin() async {
    state = state.copyWith(isLoading: true);
    final result = await ref
        .read(resinRepositoryProvider)
        .searchResins(searchItemToSellController.text);
    result.fold(
      (failure) =>
          state = state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            snackbarConfig: SnackbarConfigModel(
              title: 'Error',
              type: SnackbarEnum.error,
            ),
          ),
      (resins) => state = state.copyWith(resins: resins, isLoading: false),
    );
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: '', snackbarConfig: null);
  }

  void updateItemPrice(int index, double newPrice) {
    final items = List<SalesDetailsModel>.from(state.itemsToSell);
    final item = items[index];
    final updated =
        item.mountPrice != null
            ? item.copyWith(mountPrice: newPrice)
            : item.copyWith(price: newPrice);
    items[index] = updated;
    state = state.copyWith(itemsToSell: items);
    // Recalculate keeping existing discount and account
    final total = items.fold(
      0.0,
      (prev, e) => prev + (e.mountPrice ?? e.price ?? 0.0),
    );
    importController.text = total.toString();
    final discount = double.tryParse(discountController.text) ?? 0;
    final totalWithDiscount = total - discount;
    totalController.text = totalWithDiscount.toString();
    final account = double.tryParse(accountController.text) ?? 0;
    restController.text = (totalWithDiscount - account).toString();
  }

  void removeItemToSell(int index) {
    state = state.copyWith(
      itemsToSell: List.from(state.itemsToSell)..removeAt(index),
      snackbarConfig: SnackbarConfigModel(
        title: 'Aviso',
        type: SnackbarEnum.success,
      ),
      errorMessage: 'Item eliminado de la nota de venta',
    );
    final total = state.itemsToSell.fold(
      0.0,
      (prev, e) => prev + (e.mountPrice ?? e.price ?? 0.0),
    );
    importController.text = total.toString();
    discountController.text = '0';
    totalController.text = total.toString();
    accountController.text = '0';
    restController.text = '0';
  }

  Future<void> _getSellers() async {
    state = state.copyWith(isLoading: true);
    final result = await ref.read(sellerRepositoryProvider).getSellers();
    result.fold(
      (failure) =>
          state = state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            snackbarConfig: SnackbarConfigModel(
              title: 'Error',
              type: SnackbarEnum.error,
            ),
          ),
      (sellers) => state = state.copyWith(sellers: sellers, isLoading: false),
    );
  }

  void updateSelectedSeller(SellerModel? seller) {
    state = state.copyWith(selectedSeller: seller);
  }

  void updateSelectedBranch(BranchEnum? branch) {
    state = state.copyWith(selectedBranch: branch);
  }

  Future<void> _generatePdf(
    SalesModel sale,
    List<SalesDetailsModel> details,
  ) async {
    await ReceiptPdfService.generateAndDownloadReceipt(
      sale: sale,
      details: details,
    );
  }
}
