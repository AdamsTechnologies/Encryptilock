import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
    final crossAlign = isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        ElevatedButton.icon(
          onPressed: _launchWebsite,
          icon: const Icon(Icons.open_in_new),
          label: const Text('Visit Encryptilock.com'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Tips for Getting Started:',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: textAlign,
        ),
        const SizedBox(height: 12),
        _tipItem('Visit Encryptilock.com to find helpful information and updates.', theme, textAlign),
        _tipItem('Don’t forget your master password — it cannot be recovered.', theme, textAlign),
        _tipItem('Explore the Info tab for help and the user manual.', theme, textAlign),
        const SizedBox(height: 16),
        _buildVersionInfo(context, isCentered),
      ],
    );
  }
  // Widget _buildTipsAndWebsite(BuildContext context, {bool isCentered = false}) {
  //   final theme = Theme.of(context);
  //   final textAlign = isCentered ? TextAlign.center : TextAlign.left;
  //   final crossAlign = isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start;

  //   return Column(
  //     crossAxisAlignment: crossAlign,
  //     children: [
  //       ElevatedButton.icon(
  //         onPressed: _launchWebsite,
  //         icon: const Icon(Icons.open_in_new),
  //         label: const Text('Visit Encryptilock.com'),
  //         style: ElevatedButton.styleFrom(
  //           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  //           textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //       const SizedBox(height: 24),
  //       Text(
  //         'Tips for Getting Started:',
  //         style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
  //         textAlign: textAlign,
  //       ),
  //       const SizedBox(height: 8),
  //       Text('Visit Encryptilock.com to find helpful information and updates.', style: theme.textTheme.bodyMedium, textAlign: textAlign),
  //       Text('Don’t forget your master password — it cannot be recovered.', style: theme.textTheme.bodyMedium, textAlign: textAlign),
  //       Text('Explore the Info tab for help and the user manual.', style: theme.textTheme.bodyMedium, textAlign: textAlign),
  //       const SizedBox(height: 16),
  //       _buildVersionInfo(context, isCentered),
  //     ],
  //   );
  // }

  Widget _tipItem(String text, ThemeData theme, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: align == TextAlign.center ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_outline, size: 18, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
              textAlign: align,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context, bool isCentered) {
    final textAlign = isCentered ? TextAlign.center : TextAlign.left;
    return FutureBuilder<String>(
      future: _getVersion(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return Text(
          'Version ${snapshot.data}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
          textAlign: textAlign,
        );
      },
    );
  }

  Future<String> _getVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
    // return '1.0.0';
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
