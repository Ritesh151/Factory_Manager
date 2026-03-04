import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  static String formatInvoiceDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDisplayDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat('MM/dd/yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static DateTime? parseDateTime(String dateString) {
    try {
      return DateFormat('MMM dd, yyyy hh:mm a').parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
