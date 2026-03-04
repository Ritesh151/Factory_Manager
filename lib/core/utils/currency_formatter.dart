import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
    locale: 'en_IN',
  );

  static String format(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatCustom(double amount, {String symbol = '\$', String locale = 'en_US'}) {
    final format = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
      locale: locale,
    );
    return format.format(amount);
  }

  static String formatWithoutSymbol(double amount) {
    final format = NumberFormat.decimalPatternDigits(
      locale: 'en_US',
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  static double parse(String amount) {
    try {
      return _currencyFormat.parse(amount).toDouble();
    } catch (e) {
      return 0.0;
    }
  }
}
