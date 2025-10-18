import 'package:flutter/foundation.dart';

bool _isLoggingEnabled = false;

/// Configures FlutterTimeGuard logging.
///
/// When [enableLogs] is `true`, the [safeLog] function emits messages using
/// `debugPrint`. By default, logging is disabled to avoid noisy output.
void configureLogging({bool enableLogs = false}) {
  _isLoggingEnabled = enableLogs;
}

/// Prints [message] only when logging is enabled via [configureLogging].
///
/// Optionally accepts an [error] object that is appended to the log output.
void safeLog(Object? message, {Object? error}) {
  if (!_isLoggingEnabled) return;

  final buffer = StringBuffer('[FlutterTimeGuard]');

  if (message != null) {
    buffer.write(' $message');
  }

  if (error != null) {
    buffer.write(' | error: $error');
  }

  debugPrint(buffer.toString());
}

/// Returns whether logging is currently enabled.
bool get isLoggingEnabled => _isLoggingEnabled;
