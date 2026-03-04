import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../constants/company_info.dart';
import 'pdf_font_service.dart';

/// Service for generating professional invoice PDFs
class InvoicePdfService {
  /// Generate invoice PDF and save locally
  /// Returns the file path where PDF is saved
  static Future<String> generateAndSavePdf(InvoiceEntity invoice) async {
    final pdf = pw.Document();

    // Create PDF document
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildInvoicePage(invoice),
      ),
    );

    // Save to local file system
    final output = await _getLocalPath();
    final file = File('$output/invoice_${invoice.invoiceNumber}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  /// Generate invoice PDF as bytes (for uploading to cloud)
  static Future<List<int>> generatePdfBytes(InvoiceEntity invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildInvoicePage(invoice),
      ),
    );

    return pdf.save();
  }

  /// Build the invoice PDF page content
  static pw.Widget _buildInvoicePage(InvoiceEntity invoice) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(40),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header with company info
          _buildHeader(),
          pw.SizedBox(height: 30),

          // Invoice details section
          _buildInvoiceDetails(invoice),
          pw.SizedBox(height: 20),

          // Customer details
          _buildCustomerDetails(invoice),
          pw.SizedBox(height: 20),

          // Items table
          _buildItemsTable(invoice),
          pw.SizedBox(height: 20),

          // Totals section
          _buildTotals(invoice),
          pw.SizedBox(height: 30),

          // Notes
          if (invoice.notes != null && invoice.notes!.isNotEmpty) _buildNotes(invoice),

          // Footer
          pw.Spacer(),
          _buildFooter(),
        ],
      ),
    );
  }

  /// Build company header section
  static pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              CompanyInfo.name,
              style: PdfFontService.createTextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              CompanyInfo.address,
              style: PdfFontService.createTextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Email: ${CompanyInfo.email}',
              style: PdfFontService.createTextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Phone: ${CompanyInfo.formattedPhone}',
              style: PdfFontService.createTextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'GSTIN: ${CompanyInfo.gstin}',
              style: PdfFontService.createTextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'INVOICE',
              style: PdfFontService.createTextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build invoice metadata (number, date, due date)
  static pw.Widget _buildInvoiceDetails(InvoiceEntity invoice) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Invoice Number:', invoice.invoiceNumber),
            _buildDetailRow('Invoice Date:', dateFormat.format(invoice.invoiceDate)),
            _buildDetailRow('Due Date:', dateFormat.format(invoice.dueDate)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Text(
                'Status: ${invoice.status.toUpperCase()}',
                style: PdfFontService.createTextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: _getStatusColor(invoice.status),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build customer details section
  static pw.Widget _buildCustomerDetails(InvoiceEntity invoice) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'BILL TO:',
                style: PdfFontService.createTextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                invoice.customerName,
                style: PdfFontService.createTextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(invoice.customerEmail, style: PdfFontService.createTextStyle(fontSize: 10)),
              pw.Text(CompanyInfo.formattedPhone, style: PdfFontService.createTextStyle(fontSize: 10)),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'FROM:',
                style: PdfFontService.createTextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                CompanyInfo.name,
                style: PdfFontService.createTextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(CompanyInfo.email, style: PdfFontService.createTextStyle(fontSize: 10)),
              pw.Text(CompanyInfo.formattedPhone, style: PdfFontService.createTextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  /// Build items table with headers and rows
  static pw.Widget _buildItemsTable(InvoiceEntity invoice) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return pw.Column(
      children: [
        // Table header
        pw.Container(
          decoration: const pw.BoxDecoration(
            color: PdfColors.blue,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(5),
              topRight: pw.Radius.circular(5),
            ),
          ),
          padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  'Description',
                  style: PdfFontService.createTextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  'Qty',
                  textAlign: pw.TextAlign.right,
                  style: PdfFontService.createTextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  'Unit Price',
                  textAlign: pw.TextAlign.right,
                  style: PdfFontService.createTextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  'Total',
                  textAlign: pw.TextAlign.right,
                  style: PdfFontService.createTextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Table rows
        ...List.generate(
          invoice.items.length,
          (index) {
            final item = invoice.items[index];
            final isAlternate = index % 2 == 0;

            return pw.Container(
              decoration: pw.BoxDecoration(
                color: isAlternate ? PdfColors.grey100 : PdfColors.white,
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: PdfColors.grey300,
                    width: 0.5,
                  ),
                ),
              ),
              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          item.productName,
                          style: PdfFontService.createTextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Tax: ${item.taxRate.toStringAsFixed(1)}%',
                          style: PdfFontService.createTextStyle(fontSize: 8, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      item.quantity.toStringAsFixed(2),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      currencyFormat.format(item.unitPrice),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      currencyFormat.format(item.total),
                      textAlign: pw.TextAlign.right,
                      style: PdfFontService.createTextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build totals section
  static pw.Widget _buildTotals(InvoiceEntity invoice) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 300,
        child: pw.Column(
          children: [
            _buildTotalRow(
              'Subtotal:',
              currencyFormat.format(invoice.subtotal),
            ),
            pw.Divider(thickness: 0.5),
            _buildTotalRow(
              'Tax:',
              currencyFormat.format(invoice.taxAmount),
            ),
            pw.Divider(thickness: 1, color: PdfColors.blue),
            _buildTotalRow(
              'TOTAL:',
              currencyFormat.format(invoice.totalAmount),
              isBold: true,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Build notes section
  static pw.Widget _buildNotes(InvoiceEntity invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Notes:',
          style: PdfFontService.createTextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
          ),
          child: pw.Text(
            invoice.notes ?? '',
            style: PdfFontService.createTextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  /// Build footer
  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'Thank you for your business!',
            style: PdfFontService.createTextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Generated by SmartERP',
            style: PdfFontService.createTextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  /// Helper to build detail rows
  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.Text(label, style: PdfFontService.createTextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 10),
          pw.Text(value),
        ],
      ),
    );
  }

  /// Helper to build total rows
  static pw.Widget _buildTotalRow(
    String label,
    String value, {
    bool isBold = false,
    bool isTotal = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: PdfFontService.createTextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isTotal ? 12 : 11,
            ),
          ),
          pw.Text(
            value,
            style: PdfFontService.createTextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isTotal ? 14 : 11,
              color: isTotal ? PdfColors.blue : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Get status color for PDF
  static PdfColor _getStatusColor(String status) {
    return switch (status) {
      'paid' => PdfColors.green,
      'pending' => PdfColors.orange,
      'overdue' => PdfColors.red,
      'draft' => PdfColors.grey,
      _ => PdfColors.black,
    };
  }

  /// Get local file path for saving PDFs
  static Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${directory.path}/invoices');
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    return pdfDir.path;
  }

  /// Get the documents directory path
  static Future<String> getDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
