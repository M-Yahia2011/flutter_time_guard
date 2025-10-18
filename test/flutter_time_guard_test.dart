import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_time_guard/core/interfaces/flutter_time_guard_platform_interface.dart';
import 'package:flutter_time_guard/core/logger.dart' as logger;
import 'package:flutter_time_guard/flutter_time_guard.dart';
import 'package:flutter_time_guard/flutter_time_guard_method_channel_impl.dart';

class _MockFlutterTimeGuardPlatform extends FlutterTimeGuardPlatform {
  Function()? capturedCallback;
  bool? capturedStopListening;
  int resetCalls = 0;

  @override
  void listenToDateTimeChange(
    Function() onTimeChanged,
    bool stopListeingAfterFirstChange,
  ) {
    capturedCallback = onTimeChanged;
    capturedStopListening = stopListeingAfterFirstChange;
  }

  @override
  Future<void> reset() async {
    resetCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterTimeGuardPlatform default', () {
    test('$MethodChannelFlutterTimeGuard is the default instance', () {
      expect(
        FlutterTimeGuardPlatform.instance,
        isInstanceOf<MethodChannelFlutterTimeGuard>(),
      );
    });
  });

  group('FlutterTimeGuard - platform delegation', () {
    late FlutterTimeGuardPlatform originalInstance;
    late _MockFlutterTimeGuardPlatform mockPlatform;

    setUp(() {
      originalInstance = FlutterTimeGuardPlatform.instance;
      mockPlatform = _MockFlutterTimeGuardPlatform();
      FlutterTimeGuardPlatform.instance = mockPlatform;
    });

    tearDown(() {
      FlutterTimeGuardPlatform.instance = originalInstance;
    });

    test('listenToDateTimeChange delegates to platform instance', () {
      var invoked = false;

      FlutterTimeGuard.listenToDateTimeChange(
        onTimeChanged: () => invoked = true,
        stopListeingAfterFirstChange: true,
      );

      expect(mockPlatform.capturedCallback, isNotNull);
      expect(mockPlatform.capturedStopListening, isTrue);

      mockPlatform.capturedCallback?.call();
      expect(invoked, isTrue);
    });

    test('reset delegates to platform instance', () async {
      await FlutterTimeGuard.reset();

      expect(mockPlatform.resetCalls, 1);
    });
  });

  group('FlutterTimeGuard - logging configuration', () {
    late DebugPrintCallback originalDebugPrint;
    late List<String?> logs;

    setUp(() {
      originalDebugPrint = debugPrint;
      logs = <String?>[];
      debugPrint = (String? message, {int? wrapWidth}) {
        logs.add(message);
      };
    });

    tearDown(() {
      debugPrint = originalDebugPrint;
      logger.configureLogging(enableLogs: false);
      logs.clear();
    });

    test('configureLogging toggles the logger state', () {
      logger.configureLogging(enableLogs: true);
      expect(logger.isLoggingEnabled, isTrue);

      logger.configureLogging(enableLogs: false);
      expect(logger.isLoggingEnabled, isFalse);
    });

    test('log emits messages only when logging is enabled', () {
      logger.configureLogging(enableLogs: false);
      FlutterTimeGuard.log('should not log');

      expect(logs, isEmpty);

      logger.configureLogging(enableLogs: true);
      FlutterTimeGuard.log('visible');

      expect(logs.length, 1);
      expect(logs.single, contains('visible'));
    });
  });

  group('MethodChannelFlutterTimeGuard', () {
    const MethodChannel channel = MethodChannel('time_change_listener');
    late MethodChannelFlutterTimeGuard methodChannelImplementation;
    late TestDefaultBinaryMessenger messenger;
    late List<MethodCall> receivedCalls;

    Future<void> simulatePlatformTimeChanged() {
      final codec = const StandardMethodCodec();
      final completer = Completer<void>();

      messenger.handlePlatformMessage(
        channel.name,
        codec.encodeMethodCall(const MethodCall('onTimeChanged')),
        (_) => completer.complete(),
      );

      return completer.future;
    }

    setUp(() {
      methodChannelImplementation = MethodChannelFlutterTimeGuard();
      messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      receivedCalls = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        return receivedCalls.add(call);
      });
    });

    tearDown(() {
      messenger.setMockMethodCallHandler(channel, null);
    });

    test(
        'listenToDateTimeChange triggers callback once when stopping after first change',
        () async {
      var callCount = 0;

      methodChannelImplementation.listenToDateTimeChange(
        () async => callCount++,
        true,
      );

      await simulatePlatformTimeChanged();
      await simulatePlatformTimeChanged();

      expect(callCount, 1);
    });

    test(
        'listenToDateTimeChange triggers callback on every change when not stopping',
        () async {
      var callCount = 0;

      methodChannelImplementation.listenToDateTimeChange(
        () async => callCount++,
        false,
      );

      await simulatePlatformTimeChanged();
      await simulatePlatformTimeChanged();

      expect(callCount, 2);
    });

    test('reset clears state and invokes method channel', () async {
      methodChannelImplementation.isChanged = true;

      await methodChannelImplementation.reset();

      expect(methodChannelImplementation.isChanged, isFalse);
      expect(receivedCalls.length, 1);
      expect(receivedCalls.single.method, 'reset');
    });
    test('reset rethrows underlying invocation errors', () async {
      methodChannelImplementation.isChanged = true;
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        throw PlatformException(code: 'RESET_ERROR', message: 'failed');
      });

      await expectLater(
        () => methodChannelImplementation.reset(),
        throwsA(isA<PlatformException>()),
      );

      // isChanged should still be reset even when native call fails to avoid stale lock.
      expect(methodChannelImplementation.isChanged, isFalse);
    });
  });
}
