// import 'dart:convert';
import 'dart:typed_data';

// import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  void updateSearchDate(DateTime date) {
    state = state.copyWith(searchDate: date);
    searchController.text = DateFormat('yyyy-MM-dd').format(date);
    getSales();
  }

  @override
  SalesHistoryState build() {
    searchController.addListener(() {
      state = state.copyWith(searchText: searchController.text);
    });
    Future.microtask(getSales);
    ref.onDispose(() {
      searchController.dispose();
    });
    return const SalesHistoryState();
  }

  Future<void> getSales() async {
    state = state.copyWith(isLoading: true);
    final onlyPending = state.onlyPending;
    if (searchController.text.isNotEmpty) {
      final filter = _getFilter();
      final isDate =
          state.selectedFilter == FilterToSalesHistory.date ||
          state.selectedFilter == FilterToSalesHistory.seller;
      final result = await ref
          .read(saleRepositoryProvider)
          .getSalesByFilter(
            filter,
            searchController.text,
            isDate: isDate,
            onlyPending: onlyPending,
          );
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
        (sales) => state = state.copyWith(sales: sales, isLoading: false),
      );
      return;
    }
    final result = await ref
        .read(saleRepositoryProvider)
        .getRecentSales(limit: 20, onlyPending: onlyPending);
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
      (sales) => state = state.copyWith(sales: sales, isLoading: false),
    );
  }

  void togglePending() {
    state = state.copyWith(onlyPending: !state.onlyPending);
    getSales();
  }

  Future<void> updateSaleDate(SalesModel sale, DateTime date) async {
    if (sale.folioSale == null) return;
    state = state.copyWith(isLoading: true);
    final fecha = DateFormat('dd-MMM-yy', 'en_US').format(date);
    final fechaActualizada = DateFormat('yyyy-MM-dd').format(date);
    final result = await ref
        .read(saleRepositoryProvider)
        .updateSaleDate(sale.folioSale!, fecha, fechaActualizada);
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
          errorMessage: 'Fecha actualizada correctamente',
          snackbarConfig: SnackbarConfigModel(
            title: 'Aviso',
            type: SnackbarEnum.success,
          ),
        );
        // Audit log handled server-side by trigger trg_audit_sale_date.
        getSales();
      },
    );
  }

  void clearFilters() {
    searchController.clear();
    state = state.copyWith(
      selectedFilter: null,
      onlyPending: false,
      searchDate: null,
    );
    getSales();
  }

  String _getFilter() {
    switch (state.selectedFilter) {
      case FilterToSalesHistory.patient:
        return 'PACIENTE';
      case FilterToSalesHistory.folio:
        return 'FOLIO REMISION';
      case FilterToSalesHistory.date:
        return 'fecha_actualizada';
      case FilterToSalesHistory.seller:
        return 'AUTOR NOMBRE';
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
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            snackbarConfig: SnackbarConfigModel(
              title: 'Error',
              type: SnackbarEnum.error,
            ),
          ),
      (details) =>
          state = state.copyWith(
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
    // final rows = [
    //   ['Nombre', 'Fecha'],
    //   ...sales.map((sale) => [sale.patient, sale.date]),
    // ];
    // final csv = const ListToCsvConverter().convert(rows);
    // final bytes = utf8.encode(csv);
    // final blob = html.Blob([bytes]);
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // final anchor =
    //     html.AnchorElement(href: url)
    //       ..setAttribute("download", "pacientes.csv")
    //       ..click();
    // html.Url.revokeObjectUrl(url);
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

    final result = await ref
        .read(saleRepositoryProvider)
        .deleteSale(sale.folioSale!);
    result.fold(
      (failure) =>
          state = state.copyWith(
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
      (failure) async =>
          state = state.copyWith(
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
    final insertResult = await ref
        .read(paymentRepositoryProvider)
        .insertPayment(payment);
    await insertResult.fold(
      (failure) async =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            snackbarConfig: SnackbarConfigModel(
              title: 'Error',
              type: SnackbarEnum.error,
            ),
          ),
      (_) async {
        final newAccount = (sale.account ?? 0) + monto;
        final newRest =
            ((sale.totalWithDiscount ?? 0) - newAccount)
                .clamp(
                  0,
                  double.infinity,
                )
                .toDouble();
        final updateResult = await ref
            .read(saleRepositoryProvider)
            .updateAccountPayment(sale.id!, newAccount, newRest, fechaPago);
        updateResult.fold(
          (failure) =>
              state = state.copyWith(
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

    // ── Helpers ──────────────────────────────────────────────────────────────

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
        final parts = [
          d.mountBrand,
          d.mountModel,
        ].where((s) => s?.isNotEmpty == true).join(' ');
        return parts.isNotEmpty ? parts : (d.mountText ?? d.mount ?? 'Montura');
      }
      if (d.description?.isNotEmpty == true) return d.description!;
      if (d.text?.isNotEmpty == true) return d.text!;
      final specs = [
        d.design,
        d.line,
        d.material,
        d.technology,
      ].where((s) => s?.isNotEmpty == true).join(' / ');
      return specs.isNotEmpty ? specs : 'Lente';
    }

    String? itemSubline(SalesDetailsModel d) {
      if (d.mountPrice != null || d.mountQuantity != null) {
        return d.mountColor?.isNotEmpty == true ? d.mountColor : null;
      }
      final specs = [
        d.design,
        d.line,
        d.material,
        d.technology,
      ].where((s) => s?.isNotEmpty == true).join(' / ');
      if (specs.isNotEmpty &&
          (d.text?.isNotEmpty == true || d.description?.isNotEmpty == true)) {
        return specs;
      }
      return null;
    }

    // ── Styles ────────────────────────────────────────────────────────────────

    final fontNormal = pw.Font.courier();
    final fontBold = pw.Font.courierBold();

    pw.TextStyle ts(double size, {bool bold = false}) => pw.TextStyle(
      font: bold ? fontBold : fontNormal,
      fontSize: size,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );

    // Thin graphical line
    pw.Widget line({double thickness = 0.5, double vMargin = 3}) =>
        pw.Container(
          margin: pw.EdgeInsets.symmetric(vertical: vMargin),
          height: thickness,
          color: PdfColors.black,
        );

    // Two-column label / value row
    pw.Widget lv(
      String label,
      String value, {
      double size = 8,
      bool vBold = false,
    }) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: ts(size)),
        pw.Text(value, style: ts(size, bold: vBold)),
      ],
    );

    // ── Build ─────────────────────────────────────────────────────────────────

    final pdf = pw.Document();
    final hasDiscount = (sale.discount ?? 0) > 0;
    final totalValue =
        sale.totalWithDiscount?.toCurrency() ?? sale.total?.toCurrency() ?? '';

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
        build:
            (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // ── Header box ────────────────────────────────────
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1.5),
                  ),
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        sale.branch?.toUpperCase() ?? 'OFTALVISION',
                        style: ts(14, bold: true),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'RECIBO DE VENTA',
                        style: ts(7),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 1),
                      pw.Text(
                        'Folio #${sale.folioSale}',
                        style: ts(9, bold: true),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 6),

                // ── Sale info ─────────────────────────────────────
                lv('Fecha:', formatDate(sale.date)),
                pw.SizedBox(height: 2),
                lv('Vendedor:', sale.authorName ?? ''),
                pw.SizedBox(height: 4),
                pw.Text('Paciente:', style: ts(7)),
                pw.Text(
                  (sale.patient ?? '').toUpperCase(),
                  style: ts(9, bold: true),
                ),

                line(thickness: 1, vMargin: 5),

                // ── Column headers ────────────────────────────────
                pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 20,
                      child: pw.Text('Cant', style: ts(7, bold: true)),
                    ),
                    pw.Expanded(
                      child: pw.Text('Descripcion', style: ts(7, bold: true)),
                    ),
                    pw.Text('Precio', style: ts(7, bold: true)),
                  ],
                ),

                line(thickness: 0.5, vMargin: 2),

                // ── Items ─────────────────────────────────────────
                ...saleDetails.map((d) {
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
                            pw.SizedBox(
                              width: 20,
                              child: pw.Text(qty, style: ts(8)),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                desc,
                                style: ts(8),
                                softWrap: true,
                              ),
                            ),
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

                line(thickness: 1, vMargin: 4),

                // ── Subtotal / discount (only when applicable) ────
                if (hasDiscount) ...[
                  lv('Subtotal:', sale.total?.toCurrency() ?? ''),
                  pw.SizedBox(height: 1),
                  lv('Descuento:', '-${sale.discount?.toCurrency() ?? ''}'),
                  pw.SizedBox(height: 3),
                ],

                // ── Total highlighted box ─────────────────────────
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                  ),
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 4,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('TOTAL:', style: ts(10, bold: true)),
                      pw.Text(totalValue, style: ts(10, bold: true)),
                    ],
                  ),
                ),

                pw.SizedBox(height: 4),

                // ── Payment info ──────────────────────────────────
                lv('A cuenta:', sale.account?.toCurrency() ?? ''),
                pw.SizedBox(height: 1),
                lv('Saldo:', sale.rest?.toCurrency() ?? ''),

                pw.SizedBox(height: 10),

                // ── Footer ────────────────────────────────────────
                line(thickness: 1, vMargin: 0),
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
    // ignore: unused_local_variable
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', 'recibo${sale.folioSale}.pdf')
          ..click();
    html.Url.revokeObjectUrl(url);
  }
}
