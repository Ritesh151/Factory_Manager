import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../utils/gst_utils.dart';
import '../../features/invoice/models/invoice_model.dart';

class PDFService {
  static Future<Uint8List> generateGSTInvoice(InvoiceModel invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(),
          pw.SizedBox(height: 20),
          _buildInvoiceDetails(invoice),
          pw.SizedBox(height: 20),
          _buildProductTable(invoice),
          pw.SizedBox(height: 20),
          _buildSummary(invoice),
          pw.Spacer(),
          _buildFooter(),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(InvoiceModel.companyNameConst,
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.Text("TAX INVOICE",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(InvoiceModel.companyAddressConst, textAlign: pw.TextAlign.center),
        pw.Text("GSTIN: ${InvoiceModel.companyGSTINConst} | PAN No: ${InvoiceModel.companyPANConst}"),
        pw.Text("Contact: ${InvoiceModel.companyContactConst} | Email: ${InvoiceModel.companyEmailConst}"),
        pw.Divider(thickness: 1),
      ],
    );
  }

  static pw.Widget _buildInvoiceDetails(InvoiceModel invoice) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _detailRow("Invoice No", invoice.invoiceNo),
              _detailRow("Invoice Date", DateFormat('dd/MM/yyyy').format(invoice.date)),
              _detailRow("Transport Name", invoice.transportName),
              _detailRow("Vehicle No", invoice.vehicleNo),
              _detailRow("Delivery At", invoice.deliveryAt),
            ],
          ),
        ),
        pw.SizedBox(width: 40),
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("BILL TO:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(invoice.customerName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(invoice.customerAddress),
              pw.Text("GSTIN: ${invoice.customerGSTNo}"),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _detailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text("$label: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value),
        ],
      ),
    );
  }

  static pw.Widget _buildProductTable(InvoiceModel invoice) {
    final headers = ['SR NO', 'PRODUCT DESCRIPTION', 'HSN CODE', 'QTY', 'RATE', 'AMOUNT'];
    
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: invoice.items.map((item) => [
        item.srNo.toString(),
        item.description,
        item.hsnCode,
        item.qty.toString(),
        GSTUtils.formatCurrency(item.rate),
        GSTUtils.formatCurrency(item.amount),
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FixedColumnWidth(40),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FixedColumnWidth(80),
        3: const pw.FixedColumnWidth(50),
        4: const pw.FixedColumnWidth(80),
        5: const pw.FixedColumnWidth(80),
      },
    );
  }

  static pw.Widget _buildSummary(InvoiceModel invoice) {
    final isIntra = GSTUtils.isIntrastate(invoice.customerState);
    
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Amount in Words:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(invoice.totalInWords),
            ],
          ),
        ),
        pw.Container(
          width: 200,
          child: pw.Column(
            children: [
              _summaryRow("Subtotal", GSTUtils.formatCurrency(invoice.subtotal)),
              if (isIntra) ...[
                _summaryRow("CGST @ 9%", GSTUtils.formatCurrency(invoice.cgstAmount)),
                _summaryRow("SGST @ 9%", GSTUtils.formatCurrency(invoice.sgstAmount)),
              ] else ...[
                _summaryRow("IGST @ 18%", GSTUtils.formatCurrency(invoice.igstAmount)),
              ],
              _summaryRow("Transport Charges", GSTUtils.formatCurrency(invoice.transportCharges)),
              _summaryRow("Round Off", GSTUtils.formatCurrency(invoice.roundOff)),
              pw.Divider(),
              _summaryRow("Grand Total", GSTUtils.formatCurrency(invoice.grandTotal), bold: true),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _summaryRow(String label, String value, {bool bold = false}) {
    final style = pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Terms & Conditions:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text("1. Goods once sold will not be taken back.", style: pw.TextStyle(fontSize: 8)),
                pw.Text("2. Subject to Mumbai Jurisdiction.", style: pw.TextStyle(fontSize: 8)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(height: 30),
                pw.Text("For ${InvoiceModel.companyNameConst.toUpperCase()}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text("Authorised Signatory"),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
