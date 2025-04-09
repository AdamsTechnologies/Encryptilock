import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1000) {
      return _buildWideLayout(context);
    } else if (screenWidth > 600) {
      return _buildMediumLayout(context);
    } else {
      return _buildNarrowLayout(context);
    }
  }

  Widget _buildWideLayout(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: SizedBox(
          width: 1000,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _buildLogoAndTagline(context, theme)),
              const SizedBox(width: 40),
              Expanded(child: _buildTipsAndWebsite(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediumLayout(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 600,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _buildLogoAndTagline(context, theme)),
              const SizedBox(width: 24),
              Expanded(child: _buildTipsAndWebsite(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLogo(context),
          const SizedBox(height: 16),
          Text(
            'Encryptilock',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Data Security, just right.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildTipsAndWebsite(context, isCentered: true),
        ],
      ),
    );
  }

  Widget _buildLogoAndTagline(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogo(context),
        const SizedBox(height: 16),
        Text(
          'Encryptilock',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Data Security, just right.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTipsAndWebsite(BuildContext context, {bool isCentered = false}) {
    final theme = Theme.of(context);
    final textAlign = isCentered ? TextAlign.center : TextAlign.left;

    return Column(
      crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: _launchWebsite,
          child: const Text('Visit Our Website'),
        ),
        const SizedBox(height: 24),
        Text(
          'Helpful Tips:',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: textAlign,
        ),
        const SizedBox(height: 8),
        const Text('- Use unique passwords for each account.'),
        const Text('- Don’t forget your master password.'),
        const Text('- Enable two-factor authentication.'),
        const SizedBox(height: 16),
        Text(
          'Need support? Contact us at support@encryptilock.com',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: textAlign,
        ),
      ],
    );
  }

  Widget _buildLogo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = isDark ? 'assets/icon/encryptilockIconDarkTheme.png' : 'assets/icon/encryptilockIcon.png';

    return Image.asset(
      asset,
      width: 100,
      height: 100,
    );
  }

  void _launchWebsite() async {
    final url = Uri.https('www.encryptilock.com', '');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
