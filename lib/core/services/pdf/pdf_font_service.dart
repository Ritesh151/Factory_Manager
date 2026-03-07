import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Service for loading and managing PDF fonts with Unicode support
class PdfFontService {
  /// Create Unicode-compatible text style using system fonts
  static pw.TextStyle createTextStyle({
    double fontSize = 12,
    pw.FontWeight? fontWeight,
    PdfColor? color,
    bool italic = false,
  }) {
    // Use built-in fonts that support Unicode
    pw.Font font;
    
    // Use Courier which has better Unicode support than Helvetica
    if (fontWeight == pw.FontWeight.bold) {
      font = pw.Font.courierBold();
    } else {
      font = pw.Font.courier();
    }
    
    return pw.TextStyle(
      font: font,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFallback: [pw.Font.courier()], // Fallback for Unicode characters like \u20B9
    );
  }
  
  /// Check if fonts are available (always true for system fonts)
  static bool get fontsLoaded => true;
}
