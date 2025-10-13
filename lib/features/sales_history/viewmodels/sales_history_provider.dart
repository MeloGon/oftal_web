import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_state.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:pdf/pdf.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pdf/widgets.dart' as pw;

part 'sales_history_provider.g.dart';

@Riverpod(keepAlive: true)
class SalesHistory extends _$SalesHistory {
  final searchController = TextEditingController();
  @override
  SalesHistoryState build() {
    Future.microtask(getSales);
    ref.onDispose(() {
      searchController.dispose();
    });
    return SalesHistoryState();
  }

  final mask = MaskTextInputFormatter(
    mask: '####-##-##',
    filter: {
      '#': RegExp(r'[0-9]'),
    },
  );

  Future<void> getSales() async {
    if (searchController.text.isNotEmpty) {
      state = state.copyWith(isLoading: true);
      try {
        final filter = _getFilter();
        final response =
            (state.selectedFilter == FilterToSalesHistory.date)
                ? await Supabase.instance.client
                    .from('ventas cortas')
                    .select()
                    .eq(filter, searchController.text)
                    .order('fecha_actualizada', ascending: false)
                : await Supabase.instance.client
                    .from('ventas cortas')
                    .select()
                    .textSearch(
                      filter,
                      '%${searchController.text}%',
                      type: TextSearchType.plain,
                    );
        state = state.copyWith(
          sales: response.map((json) => SalesModel.fromJson(json)).toList(),
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
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final response = await Supabase.instance.client
          .from('ventas cortas')
          .select()
          .limit(10)
          .order('fecha_actualizada', ascending: false);
      state = state.copyWith(
        sales: response.map((json) => SalesModel.fromJson(json)).toList(),
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
    try {
      final response = await Supabase.instance.client
          .from('ventas')
          .select()
          .eq('FOLIO DE VENTA', state.saleSelectedForDetails!.folioSale!);
      state = state.copyWith(
        saleDetails:
            response.map((json) => SalesDetailsModel.fromJson(json)).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
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

  void closeSaleDetails() {
    state = state.copyWith(saleSelectedForDetails: SalesModel.empty());
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

    // ↓ Crear y descargar el archivo en Web
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute("download", "pacientes.csv")
          ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> generatePdf(
    SalesModel sale,
  ) async {
    final saleDetails = state.saleDetails;
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.roll80.copyWith(
            marginLeft: 6,
            marginRight: 6,
            marginTop: 10,
            marginBottom: 10, // en puntos
          ),
          // fuente por defecto monoespaciada ayuda a columnas alineadas
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

    // 3️⃣ Convertir a bytes
    final Uint8List bytes = await pdf.save();

    // 4️⃣ Crear un blob y descargarlo
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute(
            'download',
            'recibo${sale.folioSale}.pdf',
          )
          ..click();
    html.Url.revokeObjectUrl(url);
  }
}
