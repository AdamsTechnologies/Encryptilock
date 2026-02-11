import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoDrawerContent extends StatelessWidget {
  final String websiteUrl; // Website URL to launch

  const InfoDrawerContent({
    super.key,
    required this.websiteUrl,
  });

  void _launchWebsite() async {
    Uri url = Uri.https(websiteUrl);
    if (await canLaunchUrl(url)) {
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
      ],
    );
  }
}
