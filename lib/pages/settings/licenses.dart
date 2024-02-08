import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visualtimer/common/listmenu.dart';
import 'package:visualtimer/pages/settings/oss_licenses.dart';

class LicenseSettings extends StatelessWidget {
  const LicenseSettings({super.key});

  Future<Package> _getSelfPackage() async {
    PackageInfo packageinfo = await PackageInfo.fromPlatform();
    return Package(
      name: packageinfo.packageName,
      description: 'A visual timer app.',
      repository: 'https://github.com/sevonj/visualtimer',
      authors: [],
      version: '${packageinfo.version}+${packageinfo.buildNumber}',
      license: await rootBundle.loadString('LICENSE'),
      isMarkdown: false,
      isSdk: false,
      isDirectDependency: false,
    );
  }

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
          const Text('This app:', textScaleFactor: 1.5),
          FutureBuilder<Package>(
              future: _getSelfPackage(),
              builder: (BuildContext context, AsyncSnapshot<Package> snapshot) {
                if (snapshot.hasError) {
                  return const SizedBox();
                } else if (!snapshot.hasData) {
                  return const Text('Fetching this app...');
                }
                return _licenseTile(context, snapshot.data!);
              }),
          const SizedBox(height: 24),
          const Text(
              'This app relies on a number of other open-source projects.',
              textScaleFactor: 1.0),
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
