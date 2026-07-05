import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_time_guard/core/result.dart';
import 'package:ntp/ntp.dart';
import '../core/interfaces/flutter_time_guard_platform_interface.dart';
import '../core/interfaces/ilocal_data_source.dart';
import '../core/local_data_source_impl.dart';
import '../core/logger.dart';

/// A singleton class that validates the device's current time
/// by comparing it with the accurate network time (NTP).
///
/// Use [isDateTimeValid] to check if the device time is within an acceptable range.
class DatetimeValidator {
  DatetimeValidator._({
    ILocalDataSource? localDataSource,
    Future<DateTime> Function()? networkTimeProvider,
    Future<int?> Function()? monotonicTimeProvider,
    DateTime Function()? deviceTimeProvider,
  }) : localDataSource = localDataSource ?? LocalDataSource(),
       _networkTimeProvider = networkTimeProvider ?? NTP.now,
       _monotonicTimeProvider =
           monotonicTimeProvider ??
           FlutterTimeGuardPlatform.instance.getMonotonicTimeMillis,
       _deviceTimeProvider = deviceTimeProvider ?? DateTime.now;

  static final DatetimeValidator _instance = DatetimeValidator._();

  /// Returns the singleton instance of [DatetimeValidator].
  factory DatetimeValidator() => _instance;

  /// Creates a validator with injectable dependencies for tests.
  @visibleForTesting
  factory DatetimeValidator.forTesting({
    required ILocalDataSource localDataSource,
    required Future<DateTime> Function() networkTimeProvider,
    required Future<int?> Function() monotonicTimeProvider,
    required DateTime Function() deviceTimeProvider,
  }) => DatetimeValidator._(
    localDataSource: localDataSource,
    networkTimeProvider: networkTimeProvider,
    monotonicTimeProvider: monotonicTimeProvider,
    deviceTimeProvider: deviceTimeProvider,
  );

  ///  Used to get and store network time locally.
  final ILocalDataSource localDataSource;

  final Future<DateTime> Function() _networkTimeProvider;
  final Future<int?> Function() _monotonicTimeProvider;
  final DateTime Function() _deviceTimeProvider;
  NetworkTimeSnapshot? _runtimeSnapshot;

  /// The network time used as the reference to validate the device's current time.
  DateTime? networkTime;

  /// Validates the device's system time by comparing it with the network time (NTP).
  ///
  /// Returns `true` if the difference between the device time and the network time
  /// is within the specified [toleranceInSeconds]. Defaults to 86400 seconds (24 hours).
  ///
  /// When the latest NTP fetch fails, a cached value is reused only when it can
  /// be advanced with platform monotonic elapsed time. If no reliable cached
  /// value is available, the method returns `true` to keep the app usable; call
  /// sites that must fail closed should layer additional checks on top.
  Future<bool> isDateTimeValid({int toleranceInSeconds = 86400}) async {
    networkTime = await getNetworkTime();
    DateTime deviceTime = _deviceTimeProvider();
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
  /// Falls back to monotonic-adjusted cached NTP time if fetching fails.
  Future<DateTime?> getNetworkTime() async {
    try {
      DateTime ntpTime = await _networkTimeProvider().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          safeLog('NTP request timed out after 20 seconds');
          throw TimeoutException(
            'NTP request timed out',
            const Duration(seconds: 20),
          );
        },
      );

      safeLog('Network time: $ntpTime');

      final monotonicTimeMillis = await _getMonotonicTimeMillis();
      if (monotonicTimeMillis != null) {
        _runtimeSnapshot = NetworkTimeSnapshot(
          networkTime: ntpTime,
          monotonicTimeMillis: monotonicTimeMillis,
        );
        await localDataSource.storeNetworkTime(
          networkTime: ntpTime,
          monotonicTimeMillis: monotonicTimeMillis,
        );
      } else {
        safeLog('Monotonic time unavailable; skipping trusted time cache.');
      }

      return ntpTime;
    } catch (e) {
      DateTime? storedNTPTime = await _getNetworkTimeStoredOffline();
      safeLog('Stored Network time: $storedNTPTime', error: e);

      return storedNTPTime; // fallback to device time
    }
  }

  Future<int?> _getMonotonicTimeMillis() async {
    try {
      return await _monotonicTimeProvider();
    } catch (e) {
      safeLog('Monotonic time provider failed', error: e);
      return null;
    }
  }

  /// Retrieves previously stored network time and advances it with monotonic time.
  Future<DateTime?> _getNetworkTimeStoredOffline() async {
    final currentMonotonicTimeMillis = await _getMonotonicTimeMillis();
    if (currentMonotonicTimeMillis == null) {
      return null;
    }

    final runtimeNetworkTime = _estimateNetworkTime(
      _runtimeSnapshot,
      currentMonotonicTimeMillis,
    );
    if (runtimeNetworkTime != null) {
      safeLog('Runtime cached NTP time: $runtimeNetworkTime');
      return runtimeNetworkTime;
    }

    final Result<NetworkTimeSnapshot?> result = await localDataSource
        .getStoredNetworkTime();

    if (result is Error) {
      return null;
    } else if (result is Ok) {
      final snapshot = (result as Ok<NetworkTimeSnapshot?>).value;
      final storedNetworkTime = _estimateNetworkTime(
        snapshot,
        currentMonotonicTimeMillis,
      );
      if (storedNetworkTime != null) {
        _runtimeSnapshot = snapshot;
        safeLog('Stored NTP time: $storedNetworkTime');
      }
      return storedNetworkTime;
    }
    return null;
  }

  DateTime? _estimateNetworkTime(
    NetworkTimeSnapshot? snapshot,
    int currentMonotonicTimeMillis,
  ) {
    if (snapshot == null ||
        currentMonotonicTimeMillis < snapshot.monotonicTimeMillis) {
      safeLog('Stored monotonic time is invalid or from a previous boot.');
      return null;
    }

    final elapsedMillis =
        currentMonotonicTimeMillis - snapshot.monotonicTimeMillis;
    return snapshot.networkTime.add(Duration(milliseconds: elapsedMillis));
  }
}
