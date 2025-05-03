import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:encryptilock/frontend/providers/password_provider.dart';
import 'package:encryptilock/frontend/screens/passwords_screen.dart';
import 'package:encryptilock/frontend/screens/settings_screen.dart';
import 'package:encryptilock/frontend/screens/info_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1000) return _buildWide(context);
    if (screenWidth > 600) return _buildMedium(context);
    return _buildNarrow(context);
  }

  Widget _buildWide(BuildContext ctx) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: SizedBox(
          width: 1000,
          child: Row(
            children: [
              Expanded(child: _buildLogoSection(ctx)),
              const SizedBox(width: 40),
              Expanded(child: _buildActionSection(ctx, false)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedium(BuildContext ctx) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 600,
          child: Row(
            children: [
              Expanded(child: _buildLogoSection(ctx)),
              const SizedBox(width: 24),
              Expanded(child: _buildActionSection(ctx, false)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNarrow(BuildContext ctx) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLogoSection(ctx),
          const SizedBox(height: 24),
          _buildActionSection(ctx, true),
        ],
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final asset = isDark ? 'assets/icon/encryptilockIconDarkTheme.png' : 'assets/icon/encryptilockIcon.png';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(asset, width: 120, height: 120),
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

  Widget _buildActionSection(BuildContext context, bool centered) {
    final theme = Theme.of(context);
    final align = centered ? TextAlign.center : TextAlign.left;
    final cross = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: cross,
      children: [
        // Quick Action
        const SizedBox(height: 24),

        // Tips
        Text(
          'Tips for Getting Started:',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: align,
        ),
        const SizedBox(height: 12),
        _tipRow('Don\'t forget your master password — it cannot be recovered.', Icons.check_circle_outline, theme, align),
        _tipRow('Create secure passwords, use the generator', Icons.lock, theme, align),
        _tipRow('Update themes and configure app', Icons.settings, theme, align),
        _tipRow('Read the user manual', Icons.info_outline, theme, align),
        _tipRow('Submit feedback: from new feature requests, to bug reports or general info: ', Icons.help, theme, align),
        Align(
          alignment: centered ? Alignment.center : Alignment.centerLeft,
          child: TextButton(
            onPressed: _launchWebsite,
            child: const Text('Send Feedback'),
          ),
        ),
        // Align(
        //   alignment: centered ? Alignment.center : Alignment.centerLeft,
        //   child: TextButton(
        //     onPressed: _launchWebsite,
        //     child: const Text('Visit encryptilock.com'),
        //   ),
        // ),

        // Version
        FutureBuilder<String>(
          future: _getVersion(),
          builder: (ctx, snap) {
            if (!snap.hasData) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Version ${snap.data}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                textAlign: align,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _tipRow(String text, IconData icon, ThemeData theme, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: align == TextAlign.center ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium, textAlign: align)),
        ],
      ),
    );
  }

  Future<String> _getVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  void _launchWebsite() async {
    final url = Uri.https('www.encryptilock.com/contact', '');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }
}
