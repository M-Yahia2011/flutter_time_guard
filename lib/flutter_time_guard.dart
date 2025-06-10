import 'helpers/datetime_validator.dart';

import 'flutter_time_guard_platform_interface.dart';

class FlutterTimeGuard {
  static final DatetimeValidator datetimeValidator = DatetimeValidator();

  static Future<bool> isDateTimeValid() async {
    return await datetimeValidator.isDateTimeValid();
  }

  static void onDateTimeChanged({
    required Function() onTimeChanged,
    required bool stopListeingAfterFirstChange,
  }) => FlutterTimeGuardPlatform.instance.listenToDateTimeChange(
    onTimeChanged,
    stopListeingAfterFirstChange,
  );
}
