import 'package:flutter/material.dart';
import 'package:visualtimer/pages/timer.dart';
import 'package:visualtimer/themes/dark.dart';
import 'package:visualtimer/themes/light.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const TimerApp());
}

class TimerApp extends StatelessWidget {
  const TimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visual Timer',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const TimerPage(),
    );
  }
}
