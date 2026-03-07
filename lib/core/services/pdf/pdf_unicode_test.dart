import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_currency_helper.dart';
import 'pdf_font_service.dart';
import '../../constants/company_info.dart';

/// Test PDF generation with Unicode fonts
class PdfUnicodeTest {
  static Future<void> testUnicodePdf() async {
    final pdf = pw.Document();
    
    // Create a test page with Unicode characters
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Test company name
            pw.Text(
              CompanyInfo.name,
              style: PdfFontService.createTextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Test Indian Rupee symbol
            pw.Text(
              'Currency Test: ${PdfCurrencyHelper.rupeeSymbol}1,23,456.78',
              style: PdfFontService.createTextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 10),
            
            // Test various amounts with Rupee symbol
            pw.Text(
              'Total: ${PdfCurrencyHelper.formatINR(15000)}',
              style: PdfFontService.createTextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 10),
            
            pw.Text(
              'Subtotal: ${PdfCurrencyHelper.formatINR(12500)}',
              style: PdfFontService.createTextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 10),
            
            pw.Text(
              'GST (18%): ${PdfCurrencyHelper.formatINR(2250)}',
              style: PdfFontService.createTextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 20),
            
            // Test multiple currency formats
            pw.Text(
              'Various Amounts:',
              style: PdfFontService.createTextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            
            pw.Text(
              '${PdfCurrencyHelper.formatINR(100)}',
              style: PdfFontService.createTextStyle(fontSize: 12),
            ),
            pw.Text(
              '${PdfCurrencyHelper.formatINR(500.50)}',
              style: PdfFontService.createTextStyle(fontSize: 12),
            ),
            pw.Text(
              '${PdfCurrencyHelper.formatINR(1000.75)}',
              style: PdfFontService.createTextStyle(fontSize: 12),
            ),
            pw.Text(
              '${PdfCurrencyHelper.formatINR(50000)}',
              style: PdfFontService.createTextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
            
            // Test with different font weights
            pw.Text(
              'Bold Amount: ${PdfCurrencyHelper.formatINR(9999.99)}',
              style: PdfFontService.createTextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            
            pw.Text(
              'Regular Amount: ${PdfCurrencyHelper.formatINR(8888.88)}',
              style: PdfFontService.createTextStyle(fontSize: 14),
            ),
            
            // Test address with Unicode
            pw.Text(
              CompanyInfo.address,
              style: PdfFontService.createTextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 10),
            
            pw.Text(
              'Email: ${CompanyInfo.email}',
              style: PdfFontService.createTextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 10),
            
            pw.Text(
              'Phone: ${CompanyInfo.formattedPhone}',
              style: PdfFontService.createTextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 10),
            
            pw.Text(
              'GSTIN: ${CompanyInfo.gstin}',
              style: PdfFontService.createTextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
    
    final outputFile = File('test_unicode_pdf.pdf');
    await outputFile.writeAsBytes(await pdf.save());
    
    print('✅ Unicode PDF test completed successfully!');
    print('📄 Test PDF saved as: test_unicode_pdf.pdf');
    print('🎯 This PDF should display ${PdfCurrencyHelper.rupeeSymbol} symbols correctly without font errors.');
  }
}
