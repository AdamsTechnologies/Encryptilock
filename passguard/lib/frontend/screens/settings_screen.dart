import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passguard/frontend/providers/theme_provider.dart';
import 'package:passguard/frontend/providers/settings_provider.dart';
import 'package:passguard/frontend/theme/theme_config.dart';

import 'package:passguard/frontend/providers/snackbar_provider.dart'; // Snackbar providers!

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double? _temporaryIdleTimeout;

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer2<SettingsProvider, ThemeProvider>(
        builder: (context, settingsProvider, themeProvider, _) {
          _temporaryIdleTimeout ??= settingsProvider.idleTimeout.toDouble();

          return LayoutBuilder(
            builder: (context, constraints) {
              return isWideScreen
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildAppearanceSection(context, themeProvider, settingsProvider),
                        ),
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
                          _buildAppearanceSection(context, themeProvider, settingsProvider),
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
  Widget _buildAppearanceSection(BuildContext context, ThemeProvider themeProvider, SettingsProvider settingsProvider) {
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
                  settingsProvider.updateTheme(newThemeName);
                  context.read<SnackBarProvider>().showMessage('Theme updated to $newThemeName');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build the "Idle Timeout" section
  Widget _buildIdleTimeoutSection(SettingsProvider settingsProvider, ThemeData theme) {
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
                    value: _temporaryIdleTimeout ?? settingsProvider.idleTimeout.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: '${_temporaryIdleTimeout?.toInt()} minutes',
                    onChanged: (value) {
                      setState(() {
                        _temporaryIdleTimeout = value; // Update the temporary value
                      });
                    },
                  ),
                ),
                Text(
                  '${_temporaryIdleTimeout?.toInt()} min',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  settingsProvider.updateIdleTimeout(_temporaryIdleTimeout!.toInt());
                  context.read<SnackBarProvider>().showMessage('Idle timeout updated to ${_temporaryIdleTimeout!.toInt()} minutes');
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
//   const SettingsPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final isWideScreen = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings')),
//       body: Consumer2<SettingsProvider, ThemeProvider>(
//         builder: (context, settingsProvider, themeProvider, _) {
//           return LayoutBuilder(
//             builder: (context, constraints) {
//               return isWideScreen
//                   ? Row(
//                       children: [
//                         Expanded(child: _buildAppearanceSection(context, themeProvider, settingsProvider)),
//                         const VerticalDivider(width: 1),
//                         Expanded(
//                           child: _buildIdleTimeoutSection(
//                             settingsProvider,
//                             themeProvider.theme,
//                           ),
//                         ),
//                       ],
//                     )
//                   : SingleChildScrollView(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildAppearanceSection(context, themeProvider, settingsProvider),
//                           const Divider(height: 32),
//                           _buildIdleTimeoutSection(
//                             settingsProvider,
//                             themeProvider.theme,
//                           ),
//                         ],
//                       ),
//                     );
//             },
//           );
//         },
//       ),
//     );
//   }

//   /// Build the "Appearance" section
//   Widget _buildAppearanceSection(BuildContext context, ThemeProvider themeProvider, SettingsProvider settingsProvider) {
//     return Card(
//       margin: const EdgeInsets.all(16.0),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Appearance',
//               style: themeProvider.theme.textTheme.titleLarge,
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: ThemeConfig.themes.firstWhere(
//                 (themeName) => ThemeConfig.getTheme(themeName) == themeProvider.theme,
//                 orElse: () => 'light',
//               ),
//               items: ThemeConfig.themes
//                   .map((themeName) => DropdownMenuItem(
//                         value: themeName,
//                         child: Text(themeName),
//                       ))
//                   .toList(),
//               decoration: const InputDecoration(
//                 labelText: 'Select Theme',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (newThemeName) {
//                 if (newThemeName != null) {
//                   final newTheme = ThemeConfig.getTheme(newThemeName);
//                   themeProvider.setTheme(newTheme);
//                   settingsProvider.updateTheme(newThemeName);
//                   context.read<SnackBarProvider>().showMessage('Theme updated to $newThemeName');
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Build the "Idle Timeout" section
//   Widget _buildIdleTimeoutSection(SettingsProvider settingsProvider, ThemeData theme) {
//     return Card(
//       margin: const EdgeInsets.all(16.0),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Security / Timeout',
//               style: theme.textTheme.titleLarge,
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: Slider(
//                     value: settingsProvider.idleTimeout.toDouble(),
//                     min: 1,
//                     max: 60,
//                     divisions: 59,
//                     label: '${settingsProvider.idleTimeout} minutes',
//                     onChanged: (value) {
//                       settingsProvider.updateIdleTimeout(value.toInt()); // This should go to the onPressed for the Elevated Button
//                     },
//                   ),
//                 ),
//                 Text(
//                   '${settingsProvider.idleTimeout} min',
//                   style: theme.textTheme.bodyLarge,
//                 ),
//               ],
//             ),
//             Builder(
//               builder: (context) => ElevatedButton(
//                 onPressed: () {
//                   context.read<SnackBarProvider>().showMessage('Idle timeout updated to ${settingsProvider.idleTimeout} minutes');
//                 },
//                 child: const Text('Save Timeout'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
