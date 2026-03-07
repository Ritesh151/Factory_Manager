/// Helper methods for PDF currency formatting with Unicode support
class PdfCurrencyHelper {
  /// Format Indian Rupee amount using "INR" text instead of ₹ symbol
  /// This avoids font rendering issues in dart_pdf completely
  static String formatINR(num amount) {
    return 'INR ${amount.toStringAsFixed(2)}';
  }
  
  /// Format Indian Rupee amount without decimal places
  static String formatINRInt(num amount) {
    return 'INR ${amount.toStringAsFixed(0)}';
  }
  
  /// Get just the currency text
  static String get currencyText => 'INR';
  
  /// Create currency formatter for NumberFormat
  static String get indianCurrencySymbol => 'INR';
  
  /// Format with rupee symbol (only use if you have proper Unicode fonts)
  /// This method will cause font errors without proper fallback fonts
  static String formatINRWithSymbol(num amount) {
    return '\u20B9 ${amount.toStringAsFixed(2)}';
  }
  
  /// Get rupee symbol (only use if you have proper Unicode fonts)
  static String get rupeeSymbol => '\u20B9';
}
