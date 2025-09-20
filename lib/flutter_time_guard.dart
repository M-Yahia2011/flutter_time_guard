import 'helpers/datetime_validator.dart';

import 'core/interfaces/flutter_time_guard_platform_interface.dart';

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

  /// Validates the current system time by comparing it with the network time (NTP).
  ///
  /// Returns `true` if the system time is within the acceptable range; otherwise, returns `false`.
  ///
  /// [toleranceInSeconds] defines the maximum allowed difference, in seconds,
  /// between the device's time and the accurate network time.

  static Future<bool> isDateTimeValid({int toleranceInSeconds = 600}) async =>
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
}
