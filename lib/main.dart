import 'package:flutter/material.dart';
import 'package:visualtimer/pages/timer.dart';
import 'package:visualtimer/themes/dark.dart';
import 'package:visualtimer/themes/light.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const TimerApp());
}

class TimerApp extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.system);

  const TimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            title: 'Visual Timer',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: currentMode,
            home: const TimerPage(),
          );
        });
  }
}
