import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfProposalService {
  static Future<Uint8List> generateProposal({
    required Map<String, dynamic> professional,
    required Map<String, dynamic> client,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double total,
    required String currencySymbol,
    required String taxMethod,
    required double taxRate,
    String? proposalNumber,
    DateTime? expirationDate,
  }) async {
    final pdf = pw.Document();
    final today = DateTime.now();

    // Define colors
    final primaryColor = PdfColor.fromHex('#FF4D4F'); // Red
    final textColor = PdfColors.black;
    final lightGrey = PdfColor.fromHex('#F5F5F5');
    final darkGrey = PdfColor.fromHex('#B8B8B8');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header (Right side: Presupuesto & Date)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo / Professional details placeholder
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PRESUPUESTO',
                          style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryColor)),
                      pw.SizedBox(height: 10),
                      if (professional['companyName'] != null && professional['companyName'].isNotEmpty)
                        pw.Text(professional['companyName'],
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      pw.Text('Prof: ${professional['name'] ?? ''}',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  // Date box
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Presupuesto',
                          style: const pw.TextStyle(fontSize: 10)),
                      if (proposalNumber != null)
                        pw.Text('N° $proposalNumber',
                            style: pw.TextStyle(
                                fontSize: 12, color: primaryColor)),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        width: 120,
                        height: 20,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black),
                        ),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                                flex: 2,
                                child: pw.Center(
                                    child: pw.Text('FECHA',
                                        style:
                                            const pw.TextStyle(fontSize: 9)))),
                            pw.Container(width: 1, color: PdfColors.black),
                            pw.Expanded(
                                child: pw.Center(
                                    child: pw.Text(
                                        today.day.toString().padLeft(2, '0'),
                                        style:
                                            const pw.TextStyle(fontSize: 9)))),
                            pw.Container(width: 1, color: PdfColors.black),
                            pw.Expanded(
                                child: pw.Center(
                                    child: pw.Text(
                                        today.month.toString().padLeft(2, '0'),
                                        style:
                                            const pw.TextStyle(fontSize: 9)))),
                            pw.Container(width: 1, color: PdfColors.black),
                            pw.Expanded(
                                child: pw.Center(
                                    child: pw.Text(
                                        (today.year % 100).toString(),
                                        style:
                                            const pw.TextStyle(fontSize: 9)))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // 2. Client Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Cliente:     ', client['name'] ?? ''),
                        pw.SizedBox(height: 10),
                        _buildInfoRow(
                            'Dirección: ', client['address'] ?? ''),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Teléfono:  ', client['phone'] ?? ''),
                        pw.SizedBox(height: 10),
                        _buildInfoRow('Correo:    ', client['email'] ?? ''),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // 3. Items Table
              pw.Table(
                border: pw.TableBorder.all(color: darkGrey, width: 1),
                columnWidths: const {
                  0: pw.FixedColumnWidth(60),
                  1: pw.FlexColumnWidth(),
                  2: pw.FixedColumnWidth(80),
                  3: pw.FixedColumnWidth(80),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.white),
                    children: [
                      _buildTableHeader('Cantidad'),
                      _buildTableHeader('Producto / Servicio'),
                      _buildTableHeader('Precio'),
                      _buildTableHeader('Total'),
                    ],
                  ),
                  ...items.map((item) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(
                            item['qty']?.toString() ?? '1', pw.TextAlign.center),
                        _buildTableCell(
                            item['name'] ?? 'Ítem', pw.TextAlign.left),
                        _buildTableCell(
                            '$currencySymbol ${_formatCurrency(item['rate'] ?? 0)}',
                            pw.TextAlign.right),
                        _buildTableCell(
                            '$currencySymbol ${_formatCurrency(item['total'] ?? 0)}',
                            pw.TextAlign.right),
                      ],
                    );
                  }),
                  // Add empty rows to match web height visually if needed
                  for (var i = items.length; i < 5; i++)
                    pw.TableRow(
                      children: [
                        _buildTableCell('', pw.TextAlign.center),
                        _buildTableCell('', pw.TextAlign.center),
                        _buildTableCell('', pw.TextAlign.center),
                        _buildTableCell('', pw.TextAlign.center),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 20),

              // 4. Totals Block
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#FFF0F0'), // Light pink
                    ),
                    child: pw.Column(
                      children: [
                        if (tax > 0) ...[
                          _buildTotalRow('Subtotal', subtotal, currencySymbol),
                          pw.SizedBox(height: 5),
                          _buildTotalRow(
                              'IVA (${(taxRate * 100).toStringAsFixed(1)}%)',
                              tax,
                              currencySymbol),
                          pw.SizedBox(height: 5),
                          pw.Divider(color: darkGrey),
                          pw.SizedBox(height: 5),
                        ],
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 12)),
                            pw.Text(
                                '$currencySymbol ${_formatCurrency(total)}',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // 5. Footer (Red Block)
              pw.Container(
                height: 60,
                width: double.infinity,
                color: primaryColor,
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 20, vertical: 15),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Dirección: ${professional['address'] ?? 'Sin Dirección'}',
                      style: const pw.TextStyle(
                          color: PdfColors.white, fontSize: 10),
                    ),
                    pw.Text(
                      'Correo: ${professional['email'] ?? 'Sin Email'}',
                      style: const pw.TextStyle(
                          color: PdfColors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 2),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black, width: 0.5)),
                ),
                child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          textAlign: pw.TextAlign.center),
    );
  }

  static pw.Widget _buildTableCell(String text, pw.TextAlign align) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      constraints: const pw.BoxConstraints(minHeight: 25),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10), textAlign: align),
    );
  }

  static pw.Widget _buildTotalRow(
      String label, double amount, String currencySymbol) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        pw.Text('$currencySymbol ${_formatCurrency(amount)}',
            style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  static String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'es_AR', symbol: '', decimalDigits: 2)
        .format(amount)
        .trim();
  }
}
