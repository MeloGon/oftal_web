import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/utils/random_id_generator.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

part 'sell_provider.g.dart';

@Riverpod(keepAlive: true)
class Sell extends _$Sell {
  final searchController = TextEditingController();
  final searchItemToSellController = TextEditingController();
  final importController = TextEditingController();
  final discountController = TextEditingController();
  final totalController = TextEditingController();
  final accountController = TextEditingController();
  final restController = TextEditingController();
  final dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  SellState build() {
    dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
    ref.onDispose(() {
      searchController.dispose();
      searchItemToSellController.dispose();
      importController.dispose();
      discountController.dispose();
      totalController.dispose();
      accountController.dispose();
      restController.dispose();
      dateController.dispose();
    });
    return const SellState();
  }

  void updateDate(DateTime date) {
    selectedDate = date;
    dateController.text = DateFormat('dd-MM-yyyy').format(date);
  }

  void resetState() {
    searchController.clear();
    searchItemToSellController.clear();
    importController.clear();
    discountController.clear();
    totalController.clear();
    accountController.clear();
    restController.clear();
    selectedDate = DateTime.now();
    dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
    state = const SellState();
    state = state.copyWith(selectedInitialPaymentMethod: null);
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
        branch: state.selectedPatient?.branch,
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
    searchController.clear();
    searchItemToSellController.clear();
    importController.text = '0';
    discountController.text = '0';
    totalController.text = '0';
    accountController.text = '0';
    restController.text = '0';
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

  Future<void> generatePdf(String nombre, String fecha) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Nombre: ${state.selectedPatient?.name}',
                    style: pw.TextStyle(fontSize: 20),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Fecha: ${DateFormat('dd-MMM-yyyy', 'es_ES').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
      ),
    );

    final Uint8List bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    // ignore: unused_local_variable
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute(
            'download',
            'recibo${state.itemsToSell[0].folioSale}.pdf',
          )
          ..click();
    html.Url.revokeObjectUrl(url);
  }

  void changeRowsPerPage(int value) {
    state = state.copyWith(rowsPerPage: value);
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

  Future<void> _generatePdf(
    SalesModel sale,
    List<SalesDetailsModel> details,
  ) async {
    String formatDate(String? raw) {
      if (raw == null || raw.isEmpty) return '';
      try {
        return DateFormat('dd/MM/yyyy').format(
          DateFormat('dd-MMM-yy', 'en_US').parse(raw),
        );
      } catch (_) {
        return raw;
      }
    }

    String itemDescription(SalesDetailsModel d) {
      if (d.mountPrice != null || d.mountQuantity != null) {
        final parts = [d.mountBrand, d.mountModel]
            .where((s) => s?.isNotEmpty == true)
            .join(' ');
        return parts.isNotEmpty ? parts : (d.mountText ?? d.mount ?? 'Montura');
      }
      if (d.description?.isNotEmpty == true) return d.description!;
      if (d.text?.isNotEmpty == true) return d.text!;
      final specs = [d.design, d.line, d.material, d.technology]
          .where((s) => s?.isNotEmpty == true)
          .join(' / ');
      return specs.isNotEmpty ? specs : 'Lente';
    }

    String? itemSubline(SalesDetailsModel d) {
      if (d.mountPrice != null || d.mountQuantity != null) {
        return d.mountColor?.isNotEmpty == true ? d.mountColor : null;
      }
      final specs = [d.design, d.line, d.material, d.technology]
          .where((s) => s?.isNotEmpty == true)
          .join(' / ');
      if (specs.isNotEmpty &&
          (d.text?.isNotEmpty == true || d.description?.isNotEmpty == true)) {
        return specs;
      }
      return null;
    }

    final fontNormal = pw.Font.courier();
    final fontBold = pw.Font.courierBold();

    pw.TextStyle ts(double size, {bool bold = false}) => pw.TextStyle(
      font: bold ? fontBold : fontNormal,
      fontSize: size,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );

    pw.Widget divider({double thickness = 0.5, double vMargin = 3}) =>
        pw.Container(
          margin: pw.EdgeInsets.symmetric(vertical: vMargin),
          height: thickness,
          color: PdfColors.black,
        );

    pw.Widget lv(String label, String value, {double size = 8, bool vBold = false}) =>
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: ts(size)),
            pw.Text(value, style: ts(size, bold: vBold)),
          ],
        );

    final hasDiscount = (sale.discount ?? 0) > 0;
    final totalValue =
        sale.totalWithDiscount?.toCurrency() ?? sale.total?.toCurrency() ?? '';

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.roll80.copyWith(
            marginLeft: 11,
            marginRight: 11,
            marginTop: 0,
            marginBottom: 0,
          ),
          theme: pw.ThemeData(
            defaultTextStyle: pw.TextStyle(font: fontNormal),
          ),
        ),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1.5),
              ),
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: pw.Column(
                children: [
                  pw.Text(
                    sale.branch?.toUpperCase() ?? 'OFTALVISION',
                    style: ts(14, bold: true),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text('RECIBO DE VENTA', style: ts(7), textAlign: pw.TextAlign.center),
                  pw.SizedBox(height: 1),
                  pw.Text('Folio #${sale.folioSale}', style: ts(9, bold: true), textAlign: pw.TextAlign.center),
                ],
              ),
            ),
            pw.SizedBox(height: 6),
            lv('Fecha:', formatDate(sale.date)),
            pw.SizedBox(height: 2),
            lv('Vendedor:', sale.authorName ?? ''),
            pw.SizedBox(height: 4),
            pw.Text('Paciente:', style: ts(7)),
            pw.Text((sale.patient ?? '').toUpperCase(), style: ts(9, bold: true)),
            divider(thickness: 1, vMargin: 5),
            pw.Row(
              children: [
                pw.SizedBox(width: 20, child: pw.Text('Cant', style: ts(7, bold: true))),
                pw.Expanded(child: pw.Text('Descripcion', style: ts(7, bold: true))),
                pw.Text('Precio', style: ts(7, bold: true)),
              ],
            ),
            divider(thickness: 0.5, vMargin: 2),
            ...details.map((d) {
              final qty = d.mountQuantity ?? d.quantity ?? '1';
              final desc = itemDescription(d);
              final sub = itemSubline(d);
              final price = (d.mountPrice ?? d.price ?? 0.0).toCurrency();
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(width: 20, child: pw.Text(qty, style: ts(8))),
                        pw.Expanded(child: pw.Text(desc, style: ts(8), softWrap: true)),
                        pw.Text(price, style: ts(8)),
                      ],
                    ),
                    if (sub != null)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 20, top: 1),
                        child: pw.Text(sub, style: ts(7)),
                      ),
                  ],
                ),
              );
            }),
            divider(thickness: 1, vMargin: 4),
            if (hasDiscount) ...[
              lv('Subtotal:', sale.total?.toCurrency() ?? ''),
              pw.SizedBox(height: 1),
              lv('Descuento:', '-${sale.discount?.toCurrency() ?? ''}'),
              pw.SizedBox(height: 3),
            ],
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1),
              ),
              padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL:', style: ts(10, bold: true)),
                  pw.Text(totalValue, style: ts(10, bold: true)),
                ],
              ),
            ),
            pw.SizedBox(height: 4),
            lv('A cuenta:', sale.account?.toCurrency() ?? ''),
            pw.SizedBox(height: 1),
            lv('Saldo:', sale.rest?.toCurrency() ?? ''),
            pw.SizedBox(height: 10),
            divider(thickness: 1, vMargin: 0),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                'Gracias por su preferencia',
                style: ts(9, bold: true),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Center(
              child: pw.Text(
                formatDate(sale.date),
                style: ts(7),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );

    final Uint8List bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'recibo${sale.folioSale}.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
