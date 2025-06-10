import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../helpers/failure.dart';
import 'ilocal_data_source.dart';

class LocalDataSource implements ILocalDataSource {
  @override
  Future<Either<Failure, DateTime?>> getStoredNetworkTime() async {
    try {
      String? result = await FlutterSecureStorage().read(key: "networkTime");

      return right(DateTime.tryParse(result!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> storeNetworkTime({
    required DateTime networkTime,
  }) async {
    try {
      await FlutterSecureStorage().write(
        key: "networkTime",
        value: networkTime.toIso8601String(),
      );

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
