import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_time_guard/core/interfaces/ilocal_data_source.dart';
import 'package:flutter_time_guard/core/result.dart';
import 'package:flutter_time_guard/helpers/datetime_validator.dart';

class _FakeLocalDataSource implements ILocalDataSource {
  NetworkTimeSnapshot? snapshot;

  @override
  Future<Result<NetworkTimeSnapshot?>> getStoredNetworkTime() async {
    if (snapshot == null) {
      return Result.error(Failure('NO DATA'));
    }
    return Result.ok(snapshot);
  }

  @override
  Future<Result<void>> storeNetworkTime({
    required DateTime networkTime,
    required int monotonicTimeMillis,
  }) async {
    snapshot = NetworkTimeSnapshot(
      networkTime: networkTime,
      monotonicTimeMillis: monotonicTimeMillis,
    );
    return Result.ok(null);
  }
}

void main() {
  group('DatetimeValidator monotonic cache', () {
    test('successful NTP fetch stores network and monotonic time', () async {
      final localDataSource = _FakeLocalDataSource();
      final networkTime = DateTime.utc(2026, 7, 5, 12);

      final validator = DatetimeValidator.forTesting(
        localDataSource: localDataSource,
        networkTimeProvider: () async => networkTime,
        monotonicTimeProvider: () async => 5000,
        deviceTimeProvider: () => networkTime,
      );

      final result = await validator.getNetworkTime();

      expect(result, networkTime);
      expect(localDataSource.snapshot?.networkTime, networkTime);
      expect(localDataSource.snapshot?.monotonicTimeMillis, 5000);
    });

    test(
      'offline fallback advances cached time with monotonic delta',
      () async {
        final localDataSource = _FakeLocalDataSource()
          ..snapshot = NetworkTimeSnapshot(
            networkTime: DateTime.utc(2026, 7, 5, 12),
            monotonicTimeMillis: 1000,
          );

        final validator = DatetimeValidator.forTesting(
          localDataSource: localDataSource,
          networkTimeProvider: () async => throw Exception('offline'),
          monotonicTimeProvider: () async => 61000,
          deviceTimeProvider: () => DateTime.utc(2026, 7, 5, 12, 1),
        );

        final result = await validator.isDateTimeValid(toleranceInSeconds: 1);

        expect(result, isTrue);
        expect(validator.networkTime, DateTime.utc(2026, 7, 5, 12, 1));
      },
    );

    test('long idle period does not create a false invalid result', () async {
      final localDataSource = _FakeLocalDataSource()
        ..snapshot = NetworkTimeSnapshot(
          networkTime: DateTime.utc(2026, 7, 5, 12),
          monotonicTimeMillis: 1000,
        );

      final validator = DatetimeValidator.forTesting(
        localDataSource: localDataSource,
        networkTimeProvider: () async => throw Exception('offline'),
        monotonicTimeProvider: () async => 10801000,
        deviceTimeProvider: () => DateTime.utc(2026, 7, 5, 15),
      );

      final result = await validator.isDateTimeValid(toleranceInSeconds: 30);

      expect(result, isTrue);
      expect(validator.networkTime, DateTime.utc(2026, 7, 5, 15));
    });

    test('monotonic rollback invalidates cache and falls back open', () async {
      final localDataSource = _FakeLocalDataSource()
        ..snapshot = NetworkTimeSnapshot(
          networkTime: DateTime.utc(2026, 7, 5, 12),
          monotonicTimeMillis: 100000,
        );

      final validator = DatetimeValidator.forTesting(
        localDataSource: localDataSource,
        networkTimeProvider: () async => throw Exception('offline'),
        monotonicTimeProvider: () async => 10,
        deviceTimeProvider: () => DateTime.utc(2026, 7, 5, 20),
      );

      final result = await validator.isDateTimeValid(toleranceInSeconds: 30);

      expect(result, isTrue);
      expect(validator.networkTime, isNull);
    });
  });
}
