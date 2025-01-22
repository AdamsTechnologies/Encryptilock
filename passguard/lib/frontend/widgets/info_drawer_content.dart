import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoDrawerContent extends StatelessWidget {
  final String websiteUrl; // Website URL to launch

  const InfoDrawerContent({
    super.key,
    required this.websiteUrl,
  });

  void _launchWebsite() async {
    print("site: $websiteUrl");
    Uri url = Uri.https(websiteUrl);
    // Uri url = Uri.parse(websiteUrl); // Handle potential deep links
    if (await canLaunchUrl(url)) {
      print("Launching: $websiteUrl");
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.web_asset),
          title: const Text('Encryptilock Website'),
          onTap: _launchWebsite,
        ),
        // ListTile(
        //   leading: const Icon(Icons.logout),
        //   title: const Text('Logout'),
        //   subtitle: const Text('save and logout'),
        //   onTap: onLogout,
        // ),
      ],
    );
  }
}