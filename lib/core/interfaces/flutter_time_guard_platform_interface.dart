import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../flutter_time_guard_method_channel_impl.dart';

/// Interface for interacting with the FlutterTimeGuard plugin.
abstract class FlutterTimeGuardPlatform extends PlatformInterface {
  /// Constructs a FlutterTimeGuardPlatform.
  FlutterTimeGuardPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterTimeGuardPlatform _instance = MethodChannelFlutterTimeGuard();

  /// The default instance of [FlutterTimeGuardPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterTimeGuard].
  static FlutterTimeGuardPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterTimeGuardPlatform] when
  /// they register themselves.
  static set instance(FlutterTimeGuardPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Listen to changes in the system time done by the user, using a channel.
  /// 
  /// [onTimeChanged] - Callback function to execute when time changes
  /// [stopListeingAfterFirstChange] - Whether to stop listening after first change
  void listenToDateTimeChange(
    Function() onTimeChanged,
    bool stopListeingAfterFirstChange,
  ) {
    throw UnimplementedError(
        'listenToDateTimeChange() has not been implemented.');
  }

  /// Reset the time guard state.
  /// 
  /// This resets both Flutter and native side tracking,
  /// allowing new notifications to be triggered.
  Future<void> reset() {
    throw UnimplementedError('reset() has not been implemented.');
  }

  /// Check if the current date time is valid within tolerance.
  /// 
  /// [toleranceInSeconds] - How many seconds of difference to allow (default: 30)
  /// Returns true if time appears valid, false if potentially manipulated

}
