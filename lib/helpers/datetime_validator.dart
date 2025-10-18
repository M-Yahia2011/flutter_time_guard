import 'dart:async';
import 'package:flutter_time_guard/core/result.dart';
import 'package:ntp/ntp.dart';
import '../core/interfaces/ilocal_data_source.dart';
import '../core/local_data_source_impl.dart';
import '../core/logger.dart';

/// A singleton class that validates the device's current time
/// by comparing it with the accurate network time (NTP).
///
/// Use [isDateTimeValid] to check if the device time is within an acceptable range.
class DatetimeValidator {
  DatetimeValidator._();
  static final DatetimeValidator _instance = DatetimeValidator._();

  /// Returns the singleton instance of [DatetimeValidator].
  factory DatetimeValidator() => _instance;

  ///  Used to get and store network time locally.
  final ILocalDataSource localDataSource = LocalDataSource();

  /// The network time used as the reference to validate the device's current time.
  late DateTime? networkTime;

  /// Validates the device's system time by comparing it with the network time (NTP).
  ///
  /// Returns `true` if the difference between the device time and the network time
  /// is within the specified [toleranceInSeconds]. Defaults to 86400 seconds (24 hours).
  ///
  /// When the latest NTP fetch fails but a cached value exists, the cached time is reused.
  /// If no cached value is available, the method returns `true` to keep the app usable;
  /// call sites that must fail closed should layer additional checks on top.
  Future<bool> isDateTimeValid({int toleranceInSeconds = 86400}) async {
    networkTime = await _getNetworkTime();
    DateTime deviceTime = DateTime.now();
    safeLog('Device time: $deviceTime');
    if (networkTime == null) {
      safeLog(
        'Network time unavailable; proceeding with device time validation bypass.',
      );
      return true;
    }
    // Calculate absolute difference in seconds
    final difference = deviceTime.difference(networkTime!).inSeconds.abs();

    // Check if within tolerance
    return difference <= toleranceInSeconds;
  }

  /// Fetches the current network time using NTP.
  /// Falls back to locally stored NTP time if fetching fails.
  Future<DateTime?> _getNetworkTime() async {
    try {
      DateTime ntpTime = await NTP.now().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          safeLog('NTP request timed out after 20 seconds');
          throw TimeoutException(
              'NTP request timed out', const Duration(seconds: 5));
        },
      );

      safeLog('Network time: $ntpTime');

      localDataSource.storeNetworkTime(networkTime: ntpTime);
      return ntpTime;
    } catch (e) {
      DateTime? storedNTPTime = await _getNetworkTimeStoredOffline();
      safeLog('Stored Network time: $storedNTPTime', error: e);

      return storedNTPTime; // fallback to device time
    }
  }

  /// Retrieves previously stored network time from local storage.
  Future<DateTime?> _getNetworkTimeStoredOffline() async {
    final Result<DateTime?> result =
        await localDataSource.getStoredNetworkTime();

    if (result is Error) {
      return null;
    } else if (result is Ok) {
      var r = result as Ok;
      safeLog('Stored NTP time: ${r.value}');
      return r.value;
    }
    return null;
  }
}
