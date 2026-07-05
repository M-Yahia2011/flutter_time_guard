import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_time_guard/core/result.dart';
import 'interfaces/ilocal_data_source.dart';

/// Implementation of the local data source interface using Flutter Secure Storage.
class LocalDataSource implements ILocalDataSource {
  static const _networkTimeKey = 'trustedNetworkTime';
  static const _monotonicTimeMillisKey = 'trustedMonotonicTimeMillis';

  @override
  Future<Result<NetworkTimeSnapshot?>> getStoredNetworkTime() async {
    try {
      const storage = FlutterSecureStorage();
      final networkTimeValue = await storage.read(key: _networkTimeKey);
      final monotonicTimeValue = await storage.read(
        key: _monotonicTimeMillisKey,
      );

      if (networkTimeValue == null || monotonicTimeValue == null) {
        return Result.error(Failure('NO DATA'));
      }

      final networkTime = DateTime.tryParse(networkTimeValue);
      final monotonicTimeMillis = int.tryParse(monotonicTimeValue);
      if (networkTime == null || monotonicTimeMillis == null) {
        return Result.error(Failure('INVALID DATA'));
      }

      return Result.ok(
        NetworkTimeSnapshot(
          networkTime: networkTime,
          monotonicTimeMillis: monotonicTimeMillis,
        ),
      );
    } catch (e) {
      return Result.error(Failure(e.toString()));
    }
  }

  @override
  Future<Result<void>> storeNetworkTime({
    required DateTime networkTime,
    required int monotonicTimeMillis,
  }) async {
    try {
      const storage = FlutterSecureStorage();
      await storage.write(
        key: _networkTimeKey,
        value: networkTime.toIso8601String(),
      );
      await storage.write(
        key: _monotonicTimeMillisKey,
        value: monotonicTimeMillis.toString(),
      );

      return Result.ok(null); // success
    } catch (e) {
      return Result.error(Failure(e.toString())); // failure
    }
  }
}
