import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:ntp/ntp.dart';
import '../core/interfaces/ilocal_data_source.dart';
import '../core/interfaces/local_data_source_impl.dart';

/// This class is used to check if the device time is valid or not
///  by comparing it with the network time.
/// Use [isDateTimeValid] function to check if the device time is valid or not.
class DatetimeValidator {
  DatetimeValidator._();
  static final DatetimeValidator _instance = DatetimeValidator._();
  /// Returns the singlton of the class.
  factory DatetimeValidator() => _instance; 

  /// Dio is used to make the network request to the NTP server.
  final Dio dio = Dio();
  /// LocalDataSource is used to get/set the network time from the device.
  final ILocalDataSource localDataSource = LocalDataSource();
  /// It is the time that is used to validate the current system time.
  late DateTime? networkTime;

  /// Returns true if the device time is valid, false otherwise.
  /// [toleranceInSeconds = 5 sec] is the maximum difference in seconds between the device time and the network time (the real time).
  Future<bool> isDateTimeValid({int toleranceInSeconds = 5}) async {
    networkTime = await _getNetworkTime();
    DateTime deviceTime = DateTime.now();
    debugPrint('Device time: $deviceTime');
    if (networkTime == null) {
      return false;
    }
    // Calculate absolute difference in seconds
    final difference = deviceTime.difference(networkTime!).inSeconds.abs();

    // Check if within tolerance
    return difference <= toleranceInSeconds;
  }

  Future<DateTime?> _getNetworkTime() async {
    try {
      DateTime ntpTime = await NTP.now();
      localDataSource.storeNetworkTime(networkTime: ntpTime);
      debugPrint('Network time: $ntpTime');
      return ntpTime;
    } catch (e) {
      DateTime? storedNTPTime = await _getNetworkTimeStoredOffline();
      debugPrint('Stored Network time: $storedNTPTime');

      return storedNTPTime; // fallback to device time
    }
  }

  Future<DateTime?> _getNetworkTimeStoredOffline() async {
    DateTime? storedNetworkTime;
    Either result = await localDataSource.getStoredNetworkTime();
    result.fold((failure) {}, (res) {
      storedNetworkTime = res;
    });
    return storedNetworkTime;
  }
}
