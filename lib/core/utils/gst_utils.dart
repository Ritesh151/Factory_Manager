import 'package:intl/intl.dart';

class GSTUtils {
  /// Converts a double value to Indian Rupee format (e.g., ₹1,23,456.78)
  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 2,
    ).format(amount);
  }

  /// Calculates Round Off to nearest rupee
  static double calculateRoundOff(double total) {
    double rounded = total.roundToDouble();
    return rounded - total;
  }

  /// Converts number to Words (Indian Numbering System)
  static String convertToWords(double amount) {
    if (amount == 0) return "Zero Rupees Only";
    
    int total = amount.floor();
    int paise = ((amount - total) * 100).round();

    String result = _convert(total) + " Rupees";
    
    if (paise > 0) {
      result += " and " + _convert(paise) + " Paise";
    }
    
    return result + " Only";
  }

  static String _convert(int n) {
    if (n < 0) return "Negative " + _convert(-n);
    if (n == 0) return "";

    if (n < 20) {
      return [
        "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten",
        "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"
      ][n];
    }

    if (n < 100) {
      return [
        "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
      ][n ~/ 10] + (n % 10 != 0 ? " " + _convert(n % 10) : "");
    }

    if (n < 1000) {
      return _convert(n ~/ 100) + " Hundred" + (n % 100 != 0 ? " " + _convert(n % 100) : "");
    }

    if (n < 100000) {
      return _convert(n ~/ 1000) + " Thousand" + (n % 1000 != 0 ? " " + _convert(n % 1000) : "");
    }

    if (n < 10000000) {
      return _convert(n ~/ 100000) + " Lakh" + (n % 100000 != 0 ? " " + _convert(n % 100000) : "");
    }

    return _convert(n ~/ 10000000) + " Crore" + (n % 10000000 != 0 ? " " + _convert(n % 10000000) : "");
  }

  /// Determines if transaction is Intrastate based on State
  /// Note: Comparison usually involves Company State (Maharashtra) vs Customer State
  static bool isIntrastate(String customerState) {
    final companyState = "MAHARASHTRA";
    return customerState.toUpperCase().trim() == companyState;
  }
}
