import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Center(
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    'PassGuard v1.0.0',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _buildInfoContent(),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildInfoContent(),
            ),
    );
  }

  List<Widget> _buildInfoContent() {
    return [
      const Text('Secure your passwords with ease!'),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: _launchWebsite,
        child: const Text('Visit Website'),
      ),
      const SizedBox(height: 16),
      const Text(
        'Helpful Tips:',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text('- Use unique passwords for each account.'),
      const Text('- Never share your master password.'),
      const Text('- Enable two-factor authentication.'),
    ];
  }

  void _launchWebsite() async {
    Uri url = Uri.https('www.passguard9000.com', '');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
