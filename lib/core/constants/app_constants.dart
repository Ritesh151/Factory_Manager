/// App-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'SmartERP';
  static const String appVersion = '1.0.0';

  /// Fiscal year start month (1-based). April = 4.
  static const int fiscalYearStartMonth = 4;

  /// Low stock default threshold.
  static const int defaultLowStockThreshold = 10;

  /// Allowed GST rates (India).
  static const List<int> gstRates = [0, 5, 12, 18, 28];

  /// Invoice number format: INV-YYYY-XXXXX
  static const String invoiceNumberPrefix = 'INV';
  static const String purchaseNumberPrefix = 'PUR';

  /// Edit window for expense/purchase (hours).
  static const int editWindowHours = 24;

  /// Pagination
  static const int defaultPageSize = 50;
  static const int maxInvoiceLineItems = 100;
}
