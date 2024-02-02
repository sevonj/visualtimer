import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppearanceSettings extends StatelessWidget {
  const AppearanceSettings({super.key});

  Future<PackageInfo> _getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text("thememode"),
          ),
          RadioListTile(
              title: Text("Follow system"),
              value: 0,
              groupValue: null,
              onChanged: null),
          RadioListTile(
              title: Text("Light mode"),
              value: 0,
              groupValue: null,
              onChanged: null),
          RadioListTile(
              title: Text("Dark mode"),
              value: 0,
              groupValue: null,
              onChanged: null),
        ],
      ),
    );
  }
}
