import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:web/web.dart' as web;

class PdfWebExample extends StatelessWidget {
  const PdfWebExample({super.key});

  Future<void> generatePdf(String nombre, String fecha) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'OFTALVISION',
                      style: pw.TextStyle(fontSize: 20),
                    ),
                  ),
                  pw.Text(
                    'Folio de venta 3424944',
                    style: pw.TextStyle(fontSize: 20),
                  ),
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.max,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Nombre: $nombre',
                        style: pw.TextStyle(fontSize: 20),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Text(
                        'Fecha: $fecha',
                        style: pw.TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  pw.SizedBox(
                    width: double.infinity,
                    child: pw.ListView(
                      children: [
                        pw.Row(
                          mainAxisSize: pw.MainAxisSize.max,
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Montura mvk angelina Bondone'),
                            pw.Text('S/.1000.00'),
                          ],
                        ),
                        pw.Row(
                          mainAxisSize: pw.MainAxisSize.max,
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [pw.Text('mvk')],
                        ),
                        pw.Row(
                          mainAxisSize: pw.MainAxisSize.max,
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [pw.Text('Rojo')],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );

    final Uint8List bytes = await pdf.save();

    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'application/pdf'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = 'recibo.pdf';
    anchor.click();
    web.URL.revokeObjectURL(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar PDF Web')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await generatePdf('Kevin Melo', '12-10-2025');
          },
          child: const Text('Descargar PDF'),
        ),
      ),
    );
  }
}
