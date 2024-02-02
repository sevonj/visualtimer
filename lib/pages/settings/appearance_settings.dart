import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class AppearanceSettings extends StatefulWidget {
  const AppearanceSettings({super.key});

  static String getCurrentThemeName() {
    switch (TimerApp.themeNotifier.value) {
      case ThemeMode.system:
        return "Follow system";
      case ThemeMode.light:
        return "Light mode";
      case ThemeMode.dark:
        return "Dark mode";
    }
  }

  @override
  State<AppearanceSettings> createState() => _AppearanceSettingsState();
}

class _AppearanceSettingsState extends State<AppearanceSettings> {
  void setTheme(ThemeMode? themeMode) async {
    if (themeMode == null) return;

    setState(() {
      TimerApp.themeNotifier.value = themeMode;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("themeMode", themeMode.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: ListView(
        children: [
          RadioListTile(
              title: const Text("Follow system"),
              value: ThemeMode.system,
              groupValue: TimerApp.themeNotifier.value,
              onChanged: (ThemeMode? value) {
                setTheme(value);
              }),
          RadioListTile(
              title: const Text("Light mode"),
              value: ThemeMode.light,
              groupValue: TimerApp.themeNotifier.value,
              onChanged: (ThemeMode? value) {
                setTheme(value);
              }),
          RadioListTile(
              title: const Text("Dark mode"),
              value: ThemeMode.dark,
              groupValue: TimerApp.themeNotifier.value,
              onChanged: (ThemeMode? value) {
                setTheme(value);
              }),
        ],
      ),
    );
  }
}
