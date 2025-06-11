import 'package:dartz/dartz.dart';
import '../../helpers/failure.dart';

/// Interface for local data source
abstract class ILocalDataSource {
  /// Get the stored network time (Real time) from local storage.
  Future<Either<Failure, DateTime?>> getStoredNetworkTime();

  /// Store the network time (Real time) in local storage.
  Future<Either<Failure, void>> storeNetworkTime({
    required DateTime networkTime,
  });
}
