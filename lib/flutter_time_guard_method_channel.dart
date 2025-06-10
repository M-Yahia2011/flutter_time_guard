import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';


import 'flutter_time_guard_platform_interface.dart';

/// An implementation of [FlutterTimeGuardPlatform] that uses method channels.
class MethodChannelFlutterTimeGuard extends FlutterTimeGuardPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('time_change_listener');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }



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
        onTimeChanged();
      }
    });
  }
}
