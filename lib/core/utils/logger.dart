import 'package:flutter/foundation.dart';

/// Simple logger. Disabled in release.
class Logger {
  static bool _debug = kDebugMode;

  static void enableDebugLogging() => _debug = true;
  static void disableDebugLogging() => _debug = false;

  static void info(String message) {
    if (_debug) debugPrint('[SmartERP] $message');
  }

  static void warning(String message) {
    if (_debug) debugPrint('[SmartERP WARN] $message');
  }

  static void error(String message, [Object? error, StackTrace? stack]) {
    if (_debug) {
      debugPrint('[SmartERP ERROR] $message');
      if (error != null) debugPrint('$error');
      if (stack != null) debugPrint('$stack');
    }
  }
}
