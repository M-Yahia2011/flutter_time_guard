import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_time_guard/flutter_time_guard.dart';
import 'package:flutter_time_guard/flutter_time_guard_platform_interface.dart';
import 'package:flutter_time_guard/flutter_time_guard_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterTimeGuardPlatform
    with MockPlatformInterfaceMixin
    implements FlutterTimeGuardPlatform {

  @override

  
  @override
  void listenToDateTimeChange(Function() onTimeChanged, bool stopListeingAfterFirstChange) {

  }
}

void main() {
  final FlutterTimeGuardPlatform initialPlatform = FlutterTimeGuardPlatform.instance;

  test('$MethodChannelFlutterTimeGuard is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterTimeGuard>());
  });

 
}
