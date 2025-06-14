import 'package:flutter_time_guard/core/result.dart';

/// Interface for local data source
abstract class ILocalDataSource {
  /// Get the stored network time (Real time) from local storage.
  Future<Result<DateTime?>> getStoredNetworkTime();

  /// Store the network time (Real time) in local storage.
  Future<Result<void>> storeNetworkTime({required DateTime networkTime});
}
