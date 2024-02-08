import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visualtimer/common/listmenu.dart';
import 'package:visualtimer/main.dart';
import 'package:visualtimer/pages/settings/appearance_settings.dart';
import 'package:visualtimer/pages/settings/licenses.dart';

_launchUrl() async {
  var url = Uri.parse("https://github.com/sevonj/visualtimer");
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<PackageInfo> _getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

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
          appInfoItem(),
          gitHubItem(),
          appearanceItem(),
          vibrateItem(),
          licensesItem(),
        ],
      ),
    );
  }

  Widget appInfoItem() {
    return FractionallySizedBox(
      widthFactor: .75,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 64,
              child: Image.asset("res/app_icon_transparent.png"),
            ),
            const Padding(padding: EdgeInsets.all(8)),
            buildAppInfo(),
          ],
        ),
      ),
    );
  }

  Widget gitHubItem() {
    return const ListTile(
      title: Text("View project on GitHub"),
      subtitle: Text('Bug reports, feature requests, source code'),
      onTap: _launchUrl,
      leading: Icon(Icons.code),
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
        if (snapshot.hasError) {
          return const SizedBox();
        } else if (!snapshot.hasData) {
          return const Text('Fetching canVibrate...');
        }
        final data = snapshot.data!;
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

  Widget licensesItem() {
    return ListTile(
      title: const Text("Acknowledgements"),
      subtitle: const Text('Open-source components'),
      onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LicenseSettings()))
          .then((_) => setState(() {})),
      leading: const Icon(Icons.library_books),
    );
  }

// Fetches appinfo for appInfoItem
  FutureBuilder<PackageInfo> buildAppInfo() {
    return FutureBuilder<PackageInfo>(
      future: _getPackageInfo(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        if (snapshot.hasError) {
          return const Text('Error fetching package info.');
        } else if (!snapshot.hasData) {
          return const Text('Fetching package info...');
        }
        final data = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.appName, textScaleFactor: 1.5),
            Text(
                kDebugMode
                    ? 'version: ${data.version}+${data.buildNumber} DEBUG'
                    : 'version: ${data.version}+${data.buildNumber}',
                textAlign: TextAlign.left),
          ],
        );
      },
    );
  }
}
