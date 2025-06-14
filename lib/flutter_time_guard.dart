import 'helpers/datetime_validator.dart';

import 'core/interfaces/flutter_time_guard_platform_interface.dart';

/// use FlutterTimeGuard to listen to changes in the system time and validate current system time
class FlutterTimeGuard {
  static final DatetimeValidator _datetimeValidator = DatetimeValidator();

  /// The real time is the time that is used to validate the current system time.
  /// if null -> the real time is not set yet
  static DateTime? realTime = _datetimeValidator.networkTime;

  /// Check if the current system time is valid by comparing it to NTP.
  /// Returns true if the current system time is valid, false otherwise.
  static Future<bool> isDateTimeValid() async =>
      await _datetimeValidator.isDateTimeValid();

  /// Listen to changes in the system time done by the user in background and ignores
  /// the system automatic changes to time which is done to synchronize with the network time.
  static void listenToDateTimeChange({
    required Function() onTimeChanged,
    required bool stopListeingAfterFirstChange,
  }) => FlutterTimeGuardPlatform.instance.listenToDateTimeChange(
    onTimeChanged,
    stopListeingAfterFirstChange,
  );
}
