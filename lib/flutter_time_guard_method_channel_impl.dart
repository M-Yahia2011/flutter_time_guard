import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'core/interfaces/flutter_time_guard_platform_interface.dart';

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
        debugPrint("onTimeChanged");
        if (isChanged && stopListeingAfterFirstChange) {
          return;
        }
        isChanged = true;
        await onTimeChanged();
      }
    });
  }
}
