import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualtimer/pages/timer.dart';
import 'package:visualtimer/themes/dark.dart';
import 'package:visualtimer/themes/light.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const TimerApp());
}

class TimerApp extends StatefulWidget {
  const TimerApp({super.key});
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.system);

  @override
  State<StatefulWidget> createState() => _TimerAppState();
}

class _TimerAppState extends State<TimerApp> {
  void loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (prefs.getString('themeMode')) {
      case "ThemeMode.light":
        TimerApp.themeNotifier.value = ThemeMode.light;
      case "ThemeMode.dark":
        TimerApp.themeNotifier.value = ThemeMode.dark;
      default:
        TimerApp.themeNotifier.value = ThemeMode.system;
    }
  }

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: TimerApp.themeNotifier,
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
