import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualtimer/common/listmenu.dart';
import 'package:visualtimer/main.dart';
import 'package:visualtimer/pages/settings/about.dart';
import 'package:visualtimer/pages/settings/appearance_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void setVibrate(bool? vibrate) async {
    if (vibrate == null) return;

    setState(() {
      TimerApp.vibrateNotifier.value = vibrate;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("vibrate", vibrate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
      ),
      body: jylsListMenu(
        children: [
          appearanceItem(),
          vibrateItem(),
          aboutItem(),
        ],
      ),
    );
  }

  Widget appearanceItem() {
    return ListTile(
      title: const Text("Appearance"),
      subtitle: Text('Theme: ${AppearanceSettings.getCurrentThemeName()}'),
      onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AppearanceSettings()))
          .then((_) => setState(() {})),
      leading: const Icon(Icons.brightness_6),
    );
  }

  FutureBuilder<bool> vibrateItem() {
    return FutureBuilder<bool>(
      future: Vibrate.canVibrate,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasError || snapshot.data == false) {
          return const SizedBox();
        } else if (!snapshot.hasData) {
          return const Text('Fetching canVibrate...');
        }
        return CheckboxListTile(
          title: const Text("Vibration"),
          subtitle: const Text('Vibrate on time out'),
          secondary: const Icon(Icons.vibration),
          value: TimerApp.vibrateNotifier.value,
          onChanged: (bool? value) {
            setVibrate(value);
          },
        );
      },
    );
  }

  Widget aboutItem() {
    return ListTile(
      title: const Text("About"),
      subtitle: const Text('Learn more about this app'),
      onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AboutPage()))
          .then((_) => setState(() {})),
      leading: const Icon(Icons.info),
    );
  }
}
