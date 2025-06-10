import 'package:dartz/dartz.dart';
import '../../helpers/failure.dart';

abstract class ILocalDataSource {
  Future<Either<Failure, DateTime?>> getStoredNetworkTime();

  Future<Either<Failure, void>> storeNetworkTime({
    required DateTime networkTime,
  });
}
