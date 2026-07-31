import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/viewmodels/sales_by_seller_state.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/sales_model.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_html/html.dart' as html;

part 'sales_by_seller_provider.g.dart';

@riverpod
class SalesBySeller extends _$SalesBySeller {
  static final _fmt = DateFormat('yyyy-MM-dd');

  @override
  SalesBySellerState build() {
    final now = DateTime.now();
    Future.microtask(loadSales);
    return SalesBySellerState(
      selectedMonth: DateTime(now.year, now.month),
    );
  }

  Future<void> loadSales() async {
    state = state.copyWith(
      isLoading: true,
      sales: [],
      clearSelectedSellers: true,
    );
    final month = state.selectedMonth;
    final from = _fmt.format(DateTime(month.year, month.month, 1));
    final to = _fmt.format(DateTime(month.year, month.month + 1, 0));

    final result = await ref
        .read(saleRepositoryProvider)
        .getSalesByDateRange(from, to);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (sales) => state = state.copyWith(isLoading: false, sales: sales),
    );
  }

  void selectMonth(DateTime month) {
    state = state.copyWith(selectedMonth: DateTime(month.year, month.month));
    loadSales();
  }

  void toggleSeller(String seller) {
    final available = state.availableSellers;
    // Start from current selection (null = all active)
    final current = state.selectedSellers ?? available.toSet();
    final updated = Set<String>.from(current);
    if (updated.contains(seller)) {
      updated.remove(seller);
    } else {
      updated.add(seller);
    }
    // If all are selected again → reset to null (all)
    final isAll = updated.length == available.length;
    state = state.copyWith(
      selectedSellers: isAll ? null : updated,
      clearSelectedSellers: isAll,
    );
  }

  void selectAllSellers() {
    state = state.copyWith(clearSelectedSellers: true);
  }

  Future<void> generateSalesBySellerReportPdf() async {
    final bySeller = _groupVisibleSalesBySeller();
    if (bySeller.isEmpty) {
      state = state.copyWith(
        errorMessage: 'No hay ventas para imprimir',
        snackbarConfig: SnackbarConfigModel(
          title: 'Aviso',
          type: SnackbarEnum.info,
        ),
      );
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final pdf = pw.Document();
      final monthLabel = _monthLabel(state.selectedMonth);
      final grandTotal = _sum(
        bySeller.values.expand((sales) => sales),
        (sale) => sale.totalWithDiscount ?? sale.total ?? 0,
      );
      final grandAccount = _sum(
        bySeller.values.expand((sales) => sales),
        (sale) => sale.account ?? 0,
      );
      final grandRest = _sum(
        bySeller.values.expand((sales) => sales),
        (sale) => sale.rest ?? 0,
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(28),
          header: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Reporte de ventas por vendedor',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Periodo: $monthLabel',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
            ],
          ),
          footer: (context) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text(
                'Pagina ${context.pageNumber} de ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
          ),
          build: (context) => [
            _summaryTable(
              salesCount: bySeller.values.fold<int>(
                0,
                (sum, sales) => sum + sales.length,
              ),
              sellerCount: bySeller.length,
              total: grandTotal,
              account: grandAccount,
              rest: grandRest,
            ),
            pw.SizedBox(height: 18),
            ...bySeller.entries.expand((entry) {
              final seller = _SellerReport.fromSales(entry.key, entry.value);
              return [
                _sellerHeader(seller),
                pw.SizedBox(height: 6),
                _salesTable(entry.value),
                pw.SizedBox(height: 16),
              ];
            }),
          ],
        ),
      );

      final Uint8List bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', _reportFileName(state.selectedMonth))
        ..click();
      html.Url.revokeObjectUrl(url);

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Reporte generado correctamente',
        snackbarConfig: SnackbarConfigModel(
          title: 'Aviso',
          type: SnackbarEnum.success,
        ),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo generar el reporte',
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      );
    }
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: '', snackbarConfig: null);
  }

  Map<String, List<SalesModel>> _groupVisibleSalesBySeller() {
    final map = <String, List<SalesModel>>{};
    for (final sale in state.sales) {
      final seller = _sellerName(sale);
      if (!state.isSellerActive(seller)) continue;
      map.putIfAbsent(seller, () => []).add(sale);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  static String _sellerName(SalesModel sale) {
    final raw = sale.authorName?.trim() ?? '';
    return raw.isNotEmpty ? _toTitleCase(raw) : 'Sin vendedor';
  }

  static String _toTitleCase(String name) {
    return name
        .split(' ')
        .map((w) {
          if (w.isEmpty) return w;
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        })
        .join(' ');
  }

  static double _sum(
    Iterable<SalesModel> sales,
    double Function(SalesModel sale) value,
  ) {
    return sales.fold<double>(0, (sum, sale) => sum + value(sale));
  }

  static String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      return DateFormat('dd/MM/yyyy').format(
        DateFormat('dd-MMM-yy', 'en_US').parse(raw),
      );
    } catch (_) {}
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(raw));
    } catch (_) {}
    return raw;
  }

  static String _monthLabel(DateTime month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${months[month.month - 1]} ${month.year}';
  }

  static String _reportFileName(DateTime month) {
    final label = _monthLabel(month).toLowerCase().replaceAll(' ', '_');
    return 'ventas_por_vendedor_$label.pdf';
  }

  static pw.Widget _summaryTable({
    required int salesCount,
    required int sellerCount,
    required double total,
    required double account,
    required double rest,
  }) {
    return pw.TableHelper.fromTextArray(
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headers: const [
        'Vendedores',
        'Ventas',
        'Total ventas',
        'A cuenta',
        'Saldo pendiente',
      ],
      data: [
        [
          sellerCount.toString(),
          salesCount.toString(),
          total.toCurrency(),
          account.toCurrency(),
          rest.toCurrency(),
        ],
      ],
    );
  }

  static pw.Widget _sellerHeader(_SellerReport seller) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        border: pw.Border.all(color: PdfColors.grey500),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            seller.name,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '${seller.salesCount} ventas | Total ${seller.total.toCurrency()} | A cuenta ${seller.account.toCurrency()} | Saldo ${seller.rest.toCurrency()}',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  static pw.Widget _salesTable(List<SalesModel> sales) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: const {
        0: pw.FixedColumnWidth(70),
        1: pw.FlexColumnWidth(2.2),
        2: pw.FixedColumnWidth(70),
        3: pw.FixedColumnWidth(70),
        4: pw.FixedColumnWidth(70),
        5: pw.FixedColumnWidth(70),
      },
      headers: const [
        'Folio',
        'Paciente',
        'Fecha',
        'Total',
        'A cuenta',
        'Saldo',
      ],
      data: sales.map((sale) {
        return [
          sale.folioSale?.isNotEmpty == true ? sale.folioSale! : '-',
          sale.patient?.isNotEmpty == true ? sale.patient! : '-',
          _formatDate(sale.updatedDate ?? sale.date),
          (sale.totalWithDiscount ?? sale.total ?? 0).toCurrency(),
          (sale.account ?? 0).toCurrency(),
          (sale.rest ?? 0).toCurrency(),
        ];
      }).toList(),
    );
  }
}

class _SellerReport {
  const _SellerReport({
    required this.name,
    required this.salesCount,
    required this.total,
    required this.account,
    required this.rest,
  });

  final String name;
  final int salesCount;
  final double total;
  final double account;
  final double rest;

  factory _SellerReport.fromSales(String name, List<SalesModel> sales) {
    return _SellerReport(
      name: name,
      salesCount: sales.length,
      total: SalesBySeller._sum(
        sales,
        (sale) => sale.totalWithDiscount ?? sale.total ?? 0,
      ),
      account: SalesBySeller._sum(sales, (sale) => sale.account ?? 0),
      rest: SalesBySeller._sum(sales, (sale) => sale.rest ?? 0),
    );
  }
}
