import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visualtimer/common/listmenu.dart';
import 'package:visualtimer/pages/settings/oss_licenses.dart';

class LicenseSettings extends StatelessWidget {
  const LicenseSettings({super.key});

  Widget _licenseTile(BuildContext context, Package package) {
    return ListTile(
        title: Text(package.name),
        subtitle: Text(package.description),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => LicenseView(package))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acknowledgements'),
      ),
      body: jylsListMenu(
        children: [
          const Text('This app relies on a number of open-source projects.',
              textScaleFactor: 1),
          const SizedBox(height: 16),
          const Text('Direct dependencies:', textScaleFactor: 1.5),
          for (Package package in ossLicenses)
            if (package.isDirectDependency) _licenseTile(context, package),
          const SizedBox(height: 16),
          const Text('Indirect dependencies:', textScaleFactor: 1.5),
          for (Package package in ossLicenses)
            if (!package.isDirectDependency) _licenseTile(context, package),
        ],
      ),
    );
  }
}

class LicenseView extends StatelessWidget {
  const LicenseView(this.package, {super.key});
  final Package package;

  _launchUrl(String addr) async {
    var url = Uri.parse(addr);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(package.name),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Name'),
            subtitle: Text(package.name),
          ),
          ListTile(
            title: const Text('Description'),
            subtitle: Text(package.description),
          ),
          ListTile(
            title: const Text('Repository'),
            subtitle: Text(package.repository ?? "N/A"),
            onTap: package.repository != null
                ? () => {_launchUrl(package.repository ?? "N/A")}
                : null,
          ),
          ListTile(
            title: const Text('Version'),
            subtitle: Text(package.version),
          ),
          ListTile(
            title: const Text('License text'),
            subtitle: Text(package.license ?? "N/A"),
          ),
        ],
      ),
    );
  }
}
