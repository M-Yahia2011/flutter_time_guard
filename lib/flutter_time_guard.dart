import 'core/interfaces/flutter_time_guard_platform_interface.dart';
import 'core/logger.dart' as logger;
import 'helpers/datetime_validator.dart';

/// Provides functionality to listen for system time changes and validate the current time.
///
/// Use [FlutterTimeGuard] to detect manual changes to the system time and ensure its accuracy
/// by comparing it against the network time.
class FlutterTimeGuard {
  static final DatetimeValidator _datetimeValidator = DatetimeValidator();

  /// The reference time used to validate the current system time.
  ///
  /// If `null`, it means the real (network) time has not been retrieved or set yet.
  static DateTime? realTime = _datetimeValidator.networkTime;

  /// Enables or disables FlutterTimeGuard logging.
  ///
  /// Set [enableLogs] to `true` to allow diagnostic messages to be printed via
  /// [log]. Logging is disabled by default.
  static void configureLogging({bool enableLogs = false}) {
    logger.configureLogging(enableLogs: enableLogs);
    FlutterTimeGuardPlatform.instance.configureLogging(enableLogs: enableLogs);
  }

  /// Logs a diagnostic [message] when logging is enabled via [configureLogging].
  ///
  /// An optional [error] object can be provided to append additional context.
  static void log(Object? message, {Object? error}) {
    logger.safeLog(message, error: error);
  }

  /// Validates the current system time by comparing it with the network time (NTP).
  ///
  /// Returns `true` if the system time is within the acceptable range; otherwise, returns `false`.
  ///
  /// [toleranceInSeconds] defines the maximum allowed difference, in seconds,
  /// between the device's time and the accurate network time.
  static Future<bool> isDateTimeValid({int toleranceInSeconds = 86400}) async =>
      await _datetimeValidator.isDateTimeValid(
        toleranceInSeconds: toleranceInSeconds,
      );

  /// Listens for manual changes to the system time made by the user,
  /// while ignoring automatic time updates (e.g., synchronization with network time).
  ///
  /// The [stopListeningAfterFirstChange] parameter determines whether the listener
  /// should automatically stop after detecting the first manual time change.
  /// This is useful when showing non-dismissible dialogs to avoid stacking multiple dialogs.
  static void listenToDateTimeChange({
    required Function() onTimeChanged,
    required bool stopListeingAfterFirstChange,
  }) =>
      FlutterTimeGuardPlatform.instance.listenToDateTimeChange(
        onTimeChanged,
        stopListeingAfterFirstChange,
      );

  /// Reset the time guard state on both Flutter and native sides.
  ///
  /// This resets tracking state and allows new notifications to be triggered.
  /// Useful when:
  /// - User logs in/out
  /// - App restarts
  /// - You want to allow new time change detections after handling one
  static Future<void> reset() async {
    await FlutterTimeGuardPlatform.instance.reset();
  }
}
