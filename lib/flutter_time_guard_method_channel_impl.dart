import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'core/interfaces/flutter_time_guard_platform_interface.dart';
import 'core/logger.dart';

/// A platform-specific implementation of [FlutterTimeGuardPlatform] using method channels.
class MethodChannelFlutterTimeGuard extends FlutterTimeGuardPlatform {
  /// The method channel used to communicate with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('time_change_listener');

  /// Tracks whether a time change has already been detected.
  /// Used to prevent handling multiple callbacks when [stopListeningAfterFirstChange] is true. (Lock)
  bool isChanged = false;

  @override
  void listenToDateTimeChange(
    Function() onTimeChanged,
    bool stopListeingAfterFirstChange,
  ) {
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == 'onTimeChanged') {
        safeLog('onTimeChanged callback received');
        if (isChanged && stopListeingAfterFirstChange) {
          return;
        }
        isChanged = true;
        await onTimeChanged();
      }
    });
  }

  /// Reset the time guard state.
  /// This allows new notifications and resets the native side tracking.
  @override
  Future<void> reset() async {
    try {
      isChanged = false; // Reset Flutter side flag
      await methodChannel.invokeMethod('reset'); // Reset native side
    } catch (e) {
      safeLog('Failed to reset time guard', error: e);
      rethrow;
    }
  }

  @override
  void configureLogging({required bool enableLogs}) {
    unawaited(
      methodChannel
          .invokeMethod<void>('configureLogging', {'enableLogs': enableLogs})
          .catchError((Object error) {
            if (error is MissingPluginException) {
              return;
            }
            safeLog('Failed to configure native logging', error: error);
          }),
    );
  }
}
