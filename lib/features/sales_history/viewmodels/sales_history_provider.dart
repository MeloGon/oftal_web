import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_state.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:pdf/pdf.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pdf/widgets.dart' as pw;

part 'sales_history_provider.g.dart';

@Riverpod(keepAlive: true)
class SalesHistory extends _$SalesHistory {
  final searchController = TextEditingController();

  final mask = MaskTextInputFormatter(
    mask: '####-##-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  SalesHistoryState build() {
    Future.microtask(getSales);
    ref.onDispose(() {
      searchController.dispose();
    });
    return const SalesHistoryState();
  }

  Future<void> getSales() async {
    state = state.copyWith(isLoading: true);
    if (searchController.text.isNotEmpty) {
      final filter = _getFilter();
      final isDate = state.selectedFilter == FilterToSalesHistory.date;
      final result = await ref
          .read(saleRepositoryProvider)
          .getSalesByFilter(filter, searchController.text, isDate: isDate);
      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: failure.message,
          snackbarConfig: SnackbarConfigModel(
            title: 'Error',
            type: SnackbarEnum.error,
          ),
          isLoading: false,
        ),
        (sales) => state = state.copyWith(sales: sales, isLoading: false),
      );
      return;
    }
    final result =
        await ref.read(saleRepositoryProvider).getRecentSales(limit: 20);
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
        isLoading: false,
      ),
      (sales) => state = state.copyWith(sales: sales, isLoading: false),
    );
  }

  String _getFilter() {
    switch (state.selectedFilter) {
      case FilterToSalesHistory.patient:
        return 'PACIENTE';
      case FilterToSalesHistory.folio:
        return 'FOLIO REMISION';
      case FilterToSalesHistory.date:
        return 'fecha_actualizada';
      case null:
        return 'PACIENTE';
    }
  }

  void selectSaleForDetails(SalesModel sale) {
    state = state.copyWith(saleSelectedForDetails: sale);
    getSalesDetails();
  }

  Future<void> getSalesDetails() async {
    if (state.saleSelectedForDetails == null) return;
    state = state.copyWith(isLoading: true);
    final result = await ref
        .read(saleRepositoryProvider)
        .getSaleDetails(state.saleSelectedForDetails!.folioSale!);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (details) => state = state.copyWith(
        saleDetails: details,
        isLoading: false,
      ),
    );
  }

  void closeSaleDetails() {
    state = state.copyWith(saleSelectedForDetails: null);
  }

  void changeRowsPerPage(int value) {
    state = state.copyWith(rowsPerPage: value);
  }

  void selectFilter(FilterToSalesHistory filter) {
    state = state.copyWith(selectedFilter: filter);
    searchController.clear();
    getSales();
  }

  void exportPatientsToCsv(List<SalesModel> sales) {
    final rows = [
      ['Nombre', 'Fecha'],
      ...sales.map((sale) => [sale.patient, sale.date]),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute("download", "pacientes.csv")
          ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> deleteSale(SalesModel sale) async {
    state = state.copyWith(isLoading: true);
    if (sale.folioSale == null) return;

    final detailsResult = await ref
        .read(saleRepositoryProvider)
        .getSaleDetails(sale.folioSale!);
    await detailsResult.fold(
      (failure) async {},
      (details) async {
        for (final detail in details) {
          final mountId = detail.idMount;
          if (mountId != null && mountId != 0) {
            await ref.read(mountRepositoryProvider).incrementStock(mountId);
          }
        }
      },
    );

    if (sale.id != null) {
      await ref
          .read(paymentRepositoryProvider)
          .deletePaymentsByRemision(sale.id!);
    }

    final result =
        await ref.read(saleRepositoryProvider).deleteSale(sale.folioSale!);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (_) async {
        state = state.copyWith(
          isLoading: false,
          snackbarConfig: SnackbarConfigModel(
            title: 'Aviso',
            type: SnackbarEnum.success,
          ),
          errorMessage: 'Venta eliminada correctamente',
        );
        await getSales();
      },
    );
  }

  Future<void> finalizeSale(SalesModel sale) async {
    state = state.copyWith(isLoading: true);
    final remainingRest = sale.rest ?? 0;
    final updated = SalesModel(
      id: sale.id,
      branch: sale.branch,
      date: sale.date,
      patient: sale.patient,
      authorName: sale.authorName,
      total: sale.total,
      discount: sale.discount,
      totalWithDiscount: sale.totalWithDiscount,
      account: sale.totalWithDiscount,
      rest: 0,
      folioSale: sale.folioSale,
      updatedDate: sale.updatedDate,
    );
    final result = await ref
        .read(saleRepositoryProvider)
        .updateShortSale(updated);
    await result.fold(
      (failure) async => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (_) async {
        if (remainingRest > 0 && sale.id != null) {
          final userId = ref.read(authProvider).profile?.id;
          final payment = PaymentModel(
            idRemision: sale.id!,
            monto: remainingRest,
            fechaPago: DateTime.now().toIso8601String().substring(0, 10),
            metodoPago: 'otro',
            registradoPor: userId,
            notas: 'Liquidación de venta',
          );
          await ref.read(paymentRepositoryProvider).insertPayment(payment);
        }
        getSales();
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Venta finalizada correctamente',
          snackbarConfig: SnackbarConfigModel(
            title: 'Aviso',
            type: SnackbarEnum.success,
          ),
        );
      },
    );
  }

  Future<void> registerPayment({
    required SalesModel sale,
    required double monto,
    required String fechaPago,
    required String metodoPago,
    String? notas,
  }) async {
    state = state.copyWith(isLoading: true);
    final userId = ref.read(authProvider).profile?.id;
    final payment = PaymentModel(
      idRemision: sale.id!,
      monto: monto,
      fechaPago: fechaPago,
      metodoPago: metodoPago,
      registradoPor: userId,
      notas: notas,
    );
    final insertResult =
        await ref.read(paymentRepositoryProvider).insertPayment(payment);
    await insertResult.fold(
      (failure) async => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (_) async {
        final newAccount = (sale.account ?? 0) + monto;
        final newRest = ((sale.totalWithDiscount ?? 0) - newAccount).clamp(
          0,
          double.infinity,
        ).toDouble();
        final updateResult = await ref
            .read(saleRepositoryProvider)
            .updateAccountPayment(sale.id!, newAccount, newRest, fechaPago);
        updateResult.fold(
          (failure) => state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            snackbarConfig: SnackbarConfigModel(
              title: 'Error',
              type: SnackbarEnum.error,
            ),
          ),
          (_) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: 'Abono registrado correctamente',
              snackbarConfig: SnackbarConfigModel(
                title: 'Aviso',
                type: SnackbarEnum.success,
              ),
            );
            getSales();
          },
        );
      },
    );
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: '', snackbarConfig: null);
  }

  void clearSaleSelectedForDetails() {
    state = state.copyWith(saleSelectedForDetails: null);
  }

  Future<void> generatePdf(SalesModel sale) async {
    final saleDetails = state.saleDetails;
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.roll80.copyWith(
            marginLeft: 6,
            marginRight: 6,
            marginTop: 10,
            marginBottom: 10,
          ),
          theme: pw.ThemeData(
            defaultTextStyle: pw.TextStyle(font: pw.Font.courier()),
          ),
        ),
        build:
            (pw.Context context) => pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    sale.branch ?? '',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                ),
                pw.Text(
                  'Folio de venta ${sale.folioSale}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Paciente: ${sale.patient}',
                  style: pw.TextStyle(fontSize: 8),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Fecha: ${sale.date}',
                  style: pw.TextStyle(fontSize: 8),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Atendido por: ${sale.authorName}',
                  style: pw.TextStyle(fontSize: 8),
                ),
                pw.Divider(),
                pw.SizedBox(height: 2),
                pw.Row(
                  children: [
                    pw.Text('Cantidad', style: pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(width: 2),
                    pw.Text('Descr.', style: pw.TextStyle(fontSize: 8)),
                    pw.Spacer(),
                    pw.Text('Precio', style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.ListView(
                  children:
                      saleDetails
                          .map(
                            (saleDetail) => pw.Row(
                              mainAxisSize: pw.MainAxisSize.max,
                              children: [
                                pw.Text(
                                  saleDetail.mountQuantity ??
                                      saleDetail.quantity ??
                                      '',
                                  style: pw.TextStyle(fontSize: 8),
                                ),
                                pw.SizedBox(width: 2),
                                pw.Text(
                                  saleDetail.mountText ??
                                      saleDetail.mountModel ??
                                      saleDetail.text ??
                                      '',
                                  style: pw.TextStyle(fontSize: 8),
                                ),
                                pw.Spacer(),
                                pw.Text(
                                  saleDetail.mountPrice?.toCurrency() ??
                                      saleDetail.price?.toCurrency() ??
                                      '',
                                  style: pw.TextStyle(fontSize: 8),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.max,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Importe: ${sale.total?.toCurrency()}',
                      style: pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      'Descuento: ${sale.discount?.toCurrency()}',
                      style: pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.max,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Pago: ${sale.account?.toCurrency()}',
                      style: pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.max,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Saldo act: ${sale.rest?.toCurrency()}',
                      style: pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Gracias por su preferencia',
                    style: pw.TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
      ),
    );

    final Uint8List bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', 'recibo${sale.folioSale}.pdf')
          ..click();
    html.Url.revokeObjectUrl(url);
  }
}
