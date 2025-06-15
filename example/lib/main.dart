import 'package:flutter/material.dart';
import 'package:flutter_time_guard/flutter_time_guard.dart';

void main() {
  try {
    runApp(const MyApp());
  } catch (e) {
    debugPrint(e.toString());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TimeGuardDemoPage(),
    );
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
    // You can pass a toleranceInSeconds argument to check time validity with a tolerance.
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
        onTimeChanged: () async {
          await showAdaptiveDialog(
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
