import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passguard/frontend/providers/theme_provider.dart';
import 'package:passguard/frontend/providers/settings_provider.dart';
import 'package:passguard/frontend/theme/theme_config.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer2<SettingsProvider, ThemeProvider>(
        builder: (context, settingsProvider, themeProvider, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return isWideScreen
                  ? Row(
                      children: [
                        Expanded(child: _buildAppearanceSection(context, themeProvider)),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: _buildIdleTimeoutSection(
                            settingsProvider,
                            themeProvider.theme,
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAppearanceSection(context, themeProvider),
                          const Divider(height: 32),
                          _buildIdleTimeoutSection(
                            settingsProvider,
                            themeProvider.theme,
                          ),
                        ],
                      ),
                    );
            },
          );
        },
      ),
    );
  }
  /// Build the "Appearance" section
  Widget _buildAppearanceSection(BuildContext context, ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: themeProvider.theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: ThemeConfig.themes.firstWhere(
                (themeName) => ThemeConfig.getTheme(themeName) == themeProvider.theme,
                orElse: () => 'light',
              ),
              items: ThemeConfig.themes
                  .map((themeName) => DropdownMenuItem(
                        value: themeName,
                        child: Text(themeName),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Select Theme',
                border: OutlineInputBorder(),
              ),
              onChanged: (newThemeName) {
                if (newThemeName != null) {
                  final newTheme = ThemeConfig.getTheme(newThemeName);
                  themeProvider.setTheme(newTheme);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Theme updated to $newThemeName')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build the "Idle Timeout" section
  Widget _buildIdleTimeoutSection(
      SettingsProvider settingsProvider, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security / Timeout',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: settingsProvider.idleTimeout.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: '${settingsProvider.idleTimeout} minutes',
                    onChanged: (value) {
                      settingsProvider.updateIdleTimeout(value.toInt());
                    },
                  ),
                ),
                Text(
                  '${settingsProvider.idleTimeout} min',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Idle timeout updated to ${settingsProvider.idleTimeout} minutes',
                      ),
                    ),
                  );
                },
                child: const Text('Save Timeout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width > 600;
//     final settingsProvider = context.watch<SettingsProvider>();
//     final themeProvider = context.watch<ThemeProvider>();

//     return isDesktop
//         ? Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: ListView(
//                     children: _buildSettingsTiles(context, settingsProvider, themeProvider),
//                   ),
//                 ),
//                 const Expanded(
//                   flex: 2,
//                   child: Center(
//                     child: Text(
//                       'Settings Panel',
//                       style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         : ListView(
//             padding: const EdgeInsets.all(16.0),
//             children: _buildSettingsTiles(context, settingsProvider, themeProvider),
//           );
//   }

//   List<Widget> _buildSettingsTiles(
//       BuildContext context, SettingsProvider settingsProvider, ThemeProvider themeProvider) {
//     return [
//       // Theme Selection
//       ListTile(
//             title: const Text('App Theme'),
//             subtitle: DropdownButton<String>(
//               value: ThemeConfig.themes.firstWhere(
//                 (themeName) => themeProvider.theme == ThemeConfig.getTheme(themeName),
//                 orElse: () => 'light',
//               ),
//               onChanged: (themeName) {
//                 if (themeName != null) {
//                   themeProvider.setTheme(ThemeConfig.getTheme(themeName));
//                 }
//               },
//               items: ThemeConfig.themes
//                   .map((themeName) => DropdownMenuItem(
//                         value: themeName,
//                         child: Text(themeName),
//                       ))
//                   .toList(),
//             ),
//           ),
//       // Dark Mode
//       SwitchListTile(
//         title: const Text('Dark Mode'),
//         value: settingsProvider.isDarkMode,
//         onChanged: (value) {
//           settingsProvider.updateTheme(value);
//         },
//       ),
//       // Idle Timeout
//       ListTile(
//         title: const Text('Idle Timeout (minutes)'),
//         subtitle: Text('${settingsProvider.idleTimeout} minutes'),
//         onTap: () {
//           _showIdleTimeoutDialog(context, settingsProvider);
//         },
//       ),
//       // Advanced Theme Editor
//       ListTile(
//         title: const Text('Advanced Theme Editor'),
//         trailing: const Icon(Icons.color_lens),
//         onTap: () {
//           // Navigate to Advanced Theme Editor (to be implemented in Step 6)
//         },
//       ),
//     ];
//   }

//   void _showIdleTimeoutDialog(BuildContext context, SettingsProvider provider) {
//     final controller = TextEditingController(text: provider.idleTimeout.toString());
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Set Idle Timeout'),
//           content: TextField(
//             controller: controller,
//             keyboardType: TextInputType.number,
//             decoration: const InputDecoration(labelText: 'Minutes'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 final value = int.tryParse(controller.text);
//                 if (value != null && value > 0) {
//                   provider.updateIdleTimeout(value);
//                 }
//                 Navigator.pop(context);
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
