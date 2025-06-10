// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class TimeChangeListener {
//   static const MethodChannel _channel = MethodChannel('time_change_listener');
//    bool isChanged = false;
//    void listen(
//     Function() onTimeChanged,
//     bool stopListeingAfterFirstChange,
//   ) {
//     _channel.setMethodCallHandler((call) async {
//       if (call.method == 'onTimeChanged') {
//         if (isChanged && stopListeingAfterFirstChange) {
//           return;
//         }
//         debugPrint("onTimeChanged");
//         isChanged = true;
//         onTimeChanged();
//       }
//     });
//   }
// }
