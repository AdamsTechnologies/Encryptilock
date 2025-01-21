import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO learn how to make this work.
class InfoDrawerContent extends StatelessWidget {
  const InfoDrawerContent({super.key});

  Widget buildInfoDrawerContent(ThemeData theme) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.web_asset),
          title: const Text('Encryptilock Website'), // <-- website link
          onTap: () {_launchWebsite();},
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: const Text('Logout'),
          subtitle: const Text('save and logout'),
          onTap: () {
            // TODO handle logout
            print('logging out - actually needs implemented.');
          },
        ),
      ],
    );
  }

  void _launchWebsite() async {
    Uri url = Uri.https('www.passguard9000.com', '');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
