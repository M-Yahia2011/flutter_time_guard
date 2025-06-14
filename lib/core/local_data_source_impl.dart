import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_time_guard/core/result.dart';
import 'interfaces/ilocal_data_source.dart';

/// Implementation of the local data source interface using Flutter Secure Storage.
class LocalDataSource implements ILocalDataSource {
  @override
  Future<Result<DateTime?>> getStoredNetworkTime() async {
    try {
      String? result = await FlutterSecureStorage().read(key: "networkTime");

      if (result == null) {
        return Result.error(Failure("NO DATA"));
      }
      return Result.ok(DateTime.tryParse(result));
    } catch (e) {
      return Result.error(Failure(e.toString()));
    }
  }

  @override
  Future<Result<void>> storeNetworkTime({required DateTime networkTime}) async {
    try {
      await FlutterSecureStorage().write(
        key: "networkTime",
        value: networkTime.toIso8601String(),
      );

      return Result.ok(null); // success
    } catch (e) {
      return Result.error(Failure(e.toString())); // failure
    }
  }
}
