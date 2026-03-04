import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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
              'Currency Test: ₹1,23,456.78',
              style: PdfFontService.createTextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 10),
            
            // Test various amounts with Rupee symbol
            pw.Text(
              'Total: ₹15,000.00',
              style: PdfFontService.createTextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 10),
            
            pw.Text(
              'Subtotal: ₹12,500.00',
              style: PdfFontService.createTextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 10),
            
            pw.Text(
              'GST (18%): ₹2,250.00',
              style: PdfFontService.createTextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 20),
            
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
    
    // Save the test PDF
    final outputFile = File('test_unicode_pdf.pdf');
    await outputFile.writeAsBytes(await pdf.save());
    
    print('✅ Unicode PDF test completed successfully!');
    print('📄 Test PDF saved as: test_unicode_pdf.pdf');
    print('🎯 This PDF should display ₹ symbols correctly without font errors.');
  }
}
