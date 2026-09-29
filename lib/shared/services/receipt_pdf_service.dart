import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import 'package:oftal_web/shared/models/sales_details_model.dart';
import 'package:oftal_web/shared/models/sales_model.dart';

class ReceiptPdfService {
  ReceiptPdfService._();

  static String _formatCurrency(double? amount) {
    return 'S/ ${(amount ?? 0.0).toStringAsFixed(2)}';
  }

  static String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      return DateFormat('dd/MM/yyyy').format(
        DateFormat('dd-MMM-yy', 'en_US').parse(raw),
      );
    } catch (_) {
      return raw;
    }
  }

  static String _itemDescription(SalesDetailsModel d) {
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

  static String? _itemSubline(SalesDetailsModel d) {
    if (d.mountPrice != null || d.mountQuantity != null) {
      return d.mountColor?.isNotEmpty == true ? 'Color: ${d.mountColor}' : null;
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

  /// Genera y descarga el recibo térmico de 80mm monocromático (Propuesta Óptica Pro)
  static Future<void> generateAndDownloadReceipt({
    required SalesModel sale,
    required List<SalesDetailsModel> details,
  }) async {
    final fontNormal = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();
    final fontOblique = pw.Font.helveticaOblique();

    pw.TextStyle ts(
      double size, {
      bool bold = false,
      bool italic = false,
    }) =>
        pw.TextStyle(
          font: italic ? fontOblique : (bold ? fontBold : fontNormal),
          fontSize: size,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColors.black,
        );

    pw.Widget divider({double thickness = 0.6, double vMargin = 2.5}) =>
        pw.Container(
          margin: pw.EdgeInsets.symmetric(vertical: vMargin),
          height: thickness,
          color: PdfColors.black,
        );

    pw.Widget doubleDivider({double vMargin = 2.5}) => pw.Column(
          children: [
            pw.SizedBox(height: vMargin),
            pw.Container(height: 0.8, color: PdfColors.black),
            pw.SizedBox(height: 1.5),
            pw.Container(height: 0.8, color: PdfColors.black),
            pw.SizedBox(height: vMargin),
          ],
        );

    final hasDiscount = (sale.discount ?? 0) > 0;
    final totalAmount =
        sale.totalWithDiscount ??
        (hasDiscount ? (sale.total ?? 0) - (sale.discount ?? 0) : (sale.total ?? 0));
    final restAmount = sale.rest ?? 0.0;
    final hasPendingBalance = restAmount > 0;
    final branchName =
        (sale.branch?.isNotEmpty == true ? sale.branch! : 'MEDILENT').toUpperCase();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.roll80.copyWith(
            marginLeft: 10,
            marginRight: 10,
            marginTop: 4,
            marginBottom: 4,
          ),
          theme: pw.ThemeData(
            defaultTextStyle: pw.TextStyle(font: fontNormal),
          ),
        ),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // ─── 1. Cabecera Clínica ──────────────────────────────────
            pw.Center(
              child: pw.Text(
                branchName,
                style: ts(13, bold: true),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 1.5),
            pw.Center(
              child: pw.Text(
                'CENTRO ÓPTICO',
                style: ts(8, bold: true),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 1),
            pw.Center(
              child: pw.Text(
                'Tel: 999 999 999',
                style: ts(7.5),
                textAlign: pw.TextAlign.center,
              ),
            ),

            // ─── 2. Franja de Orden / Folio ────────────────────────────
            doubleDivider(vMargin: 3),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('RECIBO DE VENTA', style: ts(8.5, bold: true)),
                pw.Text('FOLIO: #${sale.folioSale ?? '—'}', style: ts(9, bold: true)),
              ],
            ),
            doubleDivider(vMargin: 3),

            // ─── 3. Metadatos de la Venta ─────────────────────────────
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Fecha: ${_formatDate(sale.date)}', style: ts(8)),
                pw.Text('Atención: ${sale.authorName ?? '—'}', style: ts(8)),
              ],
            ),
            pw.SizedBox(height: 3),

            // ─── 4. Recuadro de Paciente ──────────────────────────────
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.8),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
              ),
              padding: const pw.EdgeInsets.symmetric(vertical: 3.5, horizontal: 5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('PACIENTE:', style: ts(6.5, bold: true)),
                  pw.SizedBox(height: 0.5),
                  pw.Text(
                    (sale.patient ?? '').toUpperCase(),
                    style: ts(9, bold: true),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 4),

            // ─── 5. Cabecera de Productos ─────────────────────────────
            divider(thickness: 0.8, vMargin: 1),
            pw.Row(
              children: [
                pw.SizedBox(
                  width: 22,
                  child: pw.Text('CANT', style: ts(7, bold: true)),
                ),
                pw.Expanded(
                  child: pw.Text('DESCRIPCIÓN', style: ts(7, bold: true)),
                ),
                pw.Text('TOTAL', style: ts(7, bold: true)),
              ],
            ),
            divider(thickness: 0.8, vMargin: 1),

            // ─── 6. Lista de Ítems ────────────────────────────────────
            ...details.map((d) {
              final qty = d.mountQuantity ?? d.quantity ?? '1';
              final desc = _itemDescription(d);
              final sub = _itemSubline(d);
              final price = _formatCurrency(d.mountPrice ?? d.price);

              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(
                          width: 22,
                          child: pw.Text(qty, style: ts(8, bold: true)),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            desc,
                            style: ts(8, bold: true),
                            softWrap: true,
                          ),
                        ),
                        pw.Text(price, style: ts(8, bold: true)),
                      ],
                    ),
                    if (sub != null)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 22, top: 0.5),
                        child: pw.Text(sub, style: ts(7)),
                      ),
                  ],
                ),
              );
            }),

            divider(thickness: 0.8, vMargin: 2),

            // ─── 7. Subtotal y Descuento (si aplica) ────────────────────
            if (hasDiscount) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: ts(7.5)),
                  pw.Text(_formatCurrency(sale.total), style: ts(7.5)),
                ],
              ),
              pw.SizedBox(height: 1),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Descuento:', style: ts(7.5, bold: true)),
                  pw.Text('-${_formatCurrency(sale.discount)}', style: ts(7.5, bold: true)),
                ],
              ),
              pw.SizedBox(height: 2),
            ],

            // ─── 8. Cajas Financieras en Paralelo (3 Cajas) ───────────
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 0.8),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                    ),
                    padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                    child: pw.Column(
                      children: [
                        pw.Text('TOTAL VENTA', style: ts(6.5, bold: true)),
                        pw.SizedBox(height: 1),
                        pw.Text(_formatCurrency(totalAmount), style: ts(8.5, bold: true)),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 3),
                pw.Expanded(
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 0.8),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                    ),
                    padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                    child: pw.Column(
                      children: [
                        pw.Text('A CUENTA', style: ts(6.5, bold: true)),
                        pw.SizedBox(height: 1),
                        pw.Text(_formatCurrency(sale.account), style: ts(8.5, bold: true)),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 3),
                pw.Expanded(
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 1.2),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                    ),
                    padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                    child: pw.Column(
                      children: [
                        pw.Text('SALDO RESTA', style: ts(6.5, bold: true)),
                        pw.SizedBox(height: 1),
                        pw.Text(_formatCurrency(restAmount), style: ts(8.5, bold: true)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 3),

            // ─── 9. Destaque de Saldo Pendiente o Cancelado ───────────
            divider(thickness: 1, vMargin: 2),
            pw.Center(
              child: pw.Text(
                hasPendingBalance
                    ? '*** SALDO PENDIENTE: ${_formatCurrency(restAmount)} ***'
                    : '*** TOTALMENTE CANCELADO ***',
                style: ts(8.5, bold: true),
                textAlign: pw.TextAlign.center,
              ),
            ),
            divider(thickness: 1, vMargin: 2),

            // ─── 10. Aviso Importante para Retiro ─────────────────────
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(
                'IMPORTANTE: Presentar este recibo original para el retiro de sus lentes.',
                style: ts(6.5, italic: true),
                textAlign: pw.TextAlign.center,
              ),
            ),

            // ─── 11. Código de Barras Vectorial (Code-128) ─────────────
            if (sale.folioSale != null && sale.folioSale!.isNotEmpty) ...[
              pw.SizedBox(height: 3),
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: sale.folioSale!,
                  width: 135,
                  height: 32,
                  drawText: false,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 1),
              pw.Center(
                child: pw.Text(
                  '* ${sale.folioSale} *',
                  style: ts(7.5, bold: true),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],

            // ─── 12. Pie de Recibo ────────────────────────────────────
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                '¡Gracias por su preferencia!',
                style: ts(8, bold: true),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 1),
            pw.Center(
              child: pw.Text(
                _formatDate(sale.date),
                style: ts(6.5),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 4),
          ],
        ),
      ),
    );

    final Uint8List bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'recibo_${sale.folioSale ?? 'venta'}.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
