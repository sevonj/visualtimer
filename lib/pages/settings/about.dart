import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visualtimer/common/listmenu.dart';
import 'package:visualtimer/pages/settings/oss_licenses.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<Package> _getSelfPackage() async {
    PackageInfo packageinfo = await PackageInfo.fromPlatform();
    return Package(
      name: packageinfo.packageName,
      description: 'A visual timer app.',
      repository: 'https://github.com/sevonj/visualtimer',
      authors: [],
      version: packageinfo.version,
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
        title: const Text('About'),
      ),
      body: jylsListMenu(
        children: [
          appInfoItem(),
          const SizedBox(height: 24),
          gitHubItem(),
          licenseItem(),
          const SizedBox(height: 24),
          dependenciesItem(context),
        ],
      ),
    );
  }

  FutureBuilder<PackageInfo> appInfoItem() {
    String versionString;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        if (snapshot.hasError) {
          versionString = "Failed to fetch version info.";
        } else if (!snapshot.hasData) {
          versionString = "Fetching version info...";
        } else {
          PackageInfo info = snapshot.data!;
          versionString = kDebugMode
              ? 'Version ${info.version}+${info.buildNumber} DEBUG'
              : 'Version ${info.version}+${info.buildNumber}';
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 64, child: Image.asset("res/app_icon_transparent.png")),
            const Padding(padding: EdgeInsets.all(8)),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Visual Timer', textScaler: TextScaler.linear(1.5)),
              const Text('by sevonj'),
              Text(versionString),
            ])
          ],
        );
      },
    );
  }

  Widget gitHubItem() {
    return ListTile(
      title: const Text("View project on GitHub"),
      subtitle: const Text('Bug reports, feature requests, source code'),
      onTap: () => {_launchUrl("https://github.com/sevonj/visualtimer")},
      leading: const Icon(Icons.code),
    );
  }

  FutureBuilder<Package> licenseItem() {
    return FutureBuilder<Package>(
      future: _getSelfPackage(),
      builder: (BuildContext context, AsyncSnapshot<Package> snapshot) {
        if (snapshot.hasError) {
          return const SizedBox();
        } else if (!snapshot.hasData) {
          return const Text('Fetching this app...');
        }
        Package package = snapshot.data!;
        return ListTile(
            title: const Text('License information'),
            subtitle: const Text('Visual Timer is licensed under MPL 2.0.'),
            leading: const Icon(Icons.library_books),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => LicenseView(package))));
      },
    );
  }

  Widget dependenciesItem(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('This app relies on a number of other open-source projects:'),
      const SizedBox(height: 16),
      const Text('Direct dependencies:', textScaler: TextScaler.linear(1.2)),
      for (Package package in ossLicenses)
        if (package.isDirectDependency) _licenseTile(context, package),
      const SizedBox(height: 16),
      const Text('Indirect dependencies:', textScaler: TextScaler.linear(1.2)),
      for (Package package in ossLicenses)
        if (!package.isDirectDependency) _licenseTile(context, package),
    ]);
  }
}

class LicenseView extends StatelessWidget {
  const LicenseView(this.package, {super.key});

  final Package package;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('License: ${package.name}'),
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

_launchUrl(String addr) async {
  var url = Uri.parse(addr);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}
