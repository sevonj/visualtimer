import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

_launchUrl() async {
  var url = Uri.parse("https://github.com/sevonj/visualtimer");
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<PackageInfo> _getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        children: [
          FractionallySizedBox(
            widthFactor: .75,
            child: Container(
              margin: const EdgeInsets.only(top: 32, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const FlutterLogo(size: 64),
                  const Padding(padding: EdgeInsets.all(8)),
                  buildAppInfo(),
                ],
              ),
            ),
          ),
          const ListTile(
            title: Text("View project on GitHub"),
            subtitle: Text('Bug reports, feature requests, source code'),
            onTap: _launchUrl,
            leading: Icon(Icons.code),
          ),
        ],
      ),
    );
  }

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
            Text('version: ${data.version}', textAlign: TextAlign.left),
          ],
        );
      },
    );
  }
}
