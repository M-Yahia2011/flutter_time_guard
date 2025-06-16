# 🛡️ Flutter Time Guard 🛡️

A Flutter plugin to **detect system Date/Time and Time zone changes** and **validate device time** against NTP (Network Time Protocol).

Ideal for time-sensitive applications like authentication, licenses, time tracking, and fraud prevention.

## ✨ Features

- ⏰ Detect manual changes to the device's date or time.
- 🌐 Validate device time against reliable NTP servers
  with customizable tolerance for time deviation.

![Demo](https://raw.githubusercontent.com/M-Yahia2011/flutter_time_guard/main/example/assets/demo.gif)


## 🔧 Installation

```yaml
flutter pub add flutter_time_guard
```

## 🚀 Usage
1. Validate System Time
```
import 'package:flutter_time_guard/flutter_time_guard.dart';

final isValid = await FlutterTimeGuard.isDateTimeValid(toleranceInSeconds: 10); 
print('Is time valid? $isValid');
```

2. Listen to Manual Date/Time and Time zone Changes
```
FlutterTimeGuard.listenToDateTimeChange(
 onTimeChanged: () {
    // Show a warning dialog or alert user
    print('User manually changed the system time.');
  },
  stopListeingAfterFirstChange:true, // stop listening after first change
);
```
## 💡 Example
```
import 'package:flutter/material.dart';
import 'package:flutter_time_guard/flutter_time_guard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: TimeGuardDemoPage());
  }
}

class TimeGuardDemoPage extends StatefulWidget {
  const TimeGuardDemoPage({super.key});

  @override
  State<TimeGuardDemoPage> createState() => _TimeGuardDemoPageState();
}

class _TimeGuardDemoPageState extends State<TimeGuardDemoPage> {
  bool? _isValid;
  bool _isLoading = false;

  Future<void> _checkTimeValidity() async {
    setState(() => _isLoading = true);
    final result = await FlutterTimeGuard.isDateTimeValid(); 
    setState(() {
      _isValid = result;
      _isLoading = false;
    });
  }

  String _getMessage() {
    if (_isValid == null) return 'Press the button to check time validity';
    return _isValid! ? '✅ Device time is valid' : '❌ Device time is invalid';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterTimeGuard.listenToDateTimeChange(
        onTimeChanged: () {
          showAdaptiveDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(
                'User changed the date or the Time',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'This may affect the functionality of the app. Please ensure the system time is correct.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        stopListeingAfterFirstChange: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterTimeGuard Example'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getMessage(),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _checkTimeValidity,
                      child: const Text('Check Time Validity'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 🧪 TODO
 - Add unit and integration tests
 - Provide more configuration options



## 🙌 Contributions
Contributions are welcome! Please feel free to submit issues or pull requests.

## 📬 Contact
Check my profile.

