import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passguard/frontend/providers/theme_provider.dart';
import 'package:passguard/frontend/providers/settings_provider.dart';
import 'package:passguard/frontend/theme/theme_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final settingsProvider = context.watch<SettingsProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return isDesktop
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ListView(
                    children: _buildSettingsTiles(context, settingsProvider, themeProvider),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Settings Panel',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          )
        : ListView(
            padding: const EdgeInsets.all(16.0),
            children: _buildSettingsTiles(context, settingsProvider, themeProvider),
          );
  }

  List<Widget> _buildSettingsTiles(
      BuildContext context, SettingsProvider settingsProvider, ThemeProvider themeProvider) {
    return [
      // Theme Selection
      ListTile(
            title: const Text('App Theme'),
            subtitle: DropdownButton<String>(
              value: ThemeConfig.themes.firstWhere(
                (themeName) => themeProvider.theme == ThemeConfig.getTheme(themeName),
                orElse: () => 'light',
              ),
              onChanged: (themeName) {
                if (themeName != null) {
                  themeProvider.setTheme(ThemeConfig.getTheme(themeName));
                }
              },
              items: ThemeConfig.themes
                  .map((themeName) => DropdownMenuItem(
                        value: themeName,
                        child: Text(themeName),
                      ))
                  .toList(),
            ),
          ),
      // Dark Mode
      SwitchListTile(
        title: const Text('Dark Mode'),
        value: settingsProvider.isDarkMode,
        onChanged: (value) {
          settingsProvider.updateTheme(value);
        },
      ),
      // Idle Timeout
      ListTile(
        title: const Text('Idle Timeout (minutes)'),
        subtitle: Text('${settingsProvider.idleTimeout} minutes'),
        onTap: () {
          _showIdleTimeoutDialog(context, settingsProvider);
        },
      ),
      // Advanced Theme Editor
      ListTile(
        title: const Text('Advanced Theme Editor'),
        trailing: const Icon(Icons.color_lens),
        onTap: () {
          // Navigate to Advanced Theme Editor (to be implemented in Step 6)
        },
      ),
    ];
  }

  void _showIdleTimeoutDialog(BuildContext context, SettingsProvider provider) {
    final controller = TextEditingController(text: provider.idleTimeout.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Idle Timeout'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Minutes'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value > 0) {
                  provider.updateIdleTimeout(value);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final settingsProvider = context.watch<SettingsProvider>();

    return isDesktop
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ListView(
                    children: _buildSettingsTiles(context, settingsProvider),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Settings Panel',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          )
        : ListView(
            padding: const EdgeInsets.all(16.0),
            children: _buildSettingsTiles(context, settingsProvider),
          );
  }

  List<Widget> _buildSettingsTiles(BuildContext context, SettingsProvider provider) {
    return [
      SwitchListTile(
        title: const Text('Dark Mode'),
        value: provider.isDarkMode,
        onChanged: (value) {
          provider.updateTheme(value);
        },
      ),
      ListTile(
        title: const Text('Idle Timeout (minutes)'),
        subtitle: Text('${provider.idleTimeout} minutes'),
        onTap: () {
          _showIdleTimeoutDialog(context, provider);
        },
      ),
    ];
  }

  void _showIdleTimeoutDialog(BuildContext context, SettingsProvider provider) {
    final controller = TextEditingController(text: provider.idleTimeout.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Idle Timeout'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Minutes'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value > 0) {
                  provider.updateIdleTimeout(value);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
*/