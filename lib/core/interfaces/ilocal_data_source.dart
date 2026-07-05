import 'package:flutter_time_guard/core/result.dart';

/// Cached trusted time with the monotonic clock value captured alongside it.
class NetworkTimeSnapshot {
  /// Creates a cached trusted time snapshot.
  const NetworkTimeSnapshot({
    required this.networkTime,
    required this.monotonicTimeMillis,
  });

  /// Trusted network time returned by NTP.
  final DateTime networkTime;

  /// Platform monotonic elapsed time in milliseconds at capture.
  final int monotonicTimeMillis;
}

/// Interface for local data source
abstract class ILocalDataSource {
  /// Get the stored trusted time snapshot from local storage.
  Future<Result<NetworkTimeSnapshot?>> getStoredNetworkTime();

  /// Store the trusted time snapshot in local storage.
  Future<Result<void>> storeNetworkTime({
    required DateTime networkTime,
    required int monotonicTimeMillis,
  });
}
