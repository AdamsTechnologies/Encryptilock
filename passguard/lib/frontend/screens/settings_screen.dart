import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Encryptilock/frontend/providers/theme_provider.dart';
import 'package:Encryptilock/frontend/providers/settings_provider.dart';
import 'package:Encryptilock/frontend/theme/theme_config.dart';
import 'package:Encryptilock/frontend/providers/snackbar_provider.dart'; // Snackbar providers!

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double? _temporaryIdleTimeout;

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer2<SettingsProvider, ThemeProvider>(
        builder: (context, settingsProvider, themeProvider, _) {
          // Keep track of the temporary slider value for idle timeout
          _temporaryIdleTimeout ??= settingsProvider.idleTimeout.toDouble();

          return LayoutBuilder(
            builder: (context, constraints) {
              if (isWideScreen) {
                // -- Two-column layout for wider screens --
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Ensure top alignment
                  children: [
                    // Left Column
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Top/Left alignment
                          children: [
                            // _buildGeneralSection(settingsProvider, themeProvider.theme),
                            // const SizedBox(height: 16),
                            _buildAppearanceSection(context, themeProvider, settingsProvider),
                          ],
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    // Right Column
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildIdleTimeoutSection(settingsProvider, themeProvider.theme),
                            const SizedBox(height: 16),
                            _buildPasswordSettingsSection(settingsProvider, themeProvider.theme),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // -- Single-column layout for narrow/mobile screens --
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // _buildGeneralSection(settingsProvider, themeProvider.theme),
                      // const SizedBox(height: 16),
                      _buildAppearanceSection(context, themeProvider, settingsProvider),
                      const Divider(height: 32),
                      _buildIdleTimeoutSection(settingsProvider, themeProvider.theme),
                      const Divider(height: 32),
                      _buildPasswordSettingsSection(settingsProvider, themeProvider.theme),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  /// ----------------------
  /// GENERAL SETTINGS
  /// ----------------------
  Widget _buildGeneralSection(SettingsProvider settingsProvider, ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('General', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            // Landing Page Selection
            DropdownButtonFormField<String>(
              value: settingsProvider.landingPage,
              items: const [
                DropdownMenuItem(value: 'dashboard', child: Text('Dashboard')),
                DropdownMenuItem(value: 'passwords', child: Text('Passwords')),
                DropdownMenuItem(value: 'settings', child: Text('Settings')),
              ],
              decoration: const InputDecoration(
                labelText: 'Default Landing Page',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.updateLandingPage(value);
                  context.read<SnackBarProvider>().showMessage('Landing page updated to "$value"');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ----------------------
  /// APPEARANCE
  /// ----------------------
  Widget _buildAppearanceSection(
    BuildContext context,
    ThemeProvider themeProvider,
    SettingsProvider settingsProvider,
  ) {
    // Figure out which themeName currently matches the active ThemeData
    final currentThemeName = ThemeConfig.themes.firstWhere(
      (themeName) => ThemeConfig.getTheme(themeName) == themeProvider.theme,
      orElse: () => 'light',
    );

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appearance', style: themeProvider.theme.textTheme.titleLarge),
            const SizedBox(height: 16),

            // Rewritten to use DropdownMenu (M3) instead of DropdownButtonFormField
            Container(
              width: double.infinity, // Takes full width of parent
              child: DropdownButtonFormField<String>(
                value: currentThemeName,
                decoration: InputDecoration(
                  labelText: 'Select Theme',
                  // This ensures the dropdown matches parent width
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                // This is critical - it controls the dropdown items width
                isExpanded: true,
                // This controls the alignment of the dropdown list
                alignment: AlignmentDirectional.centerStart,
                // Optional: customize the button
                icon: Icon(Icons.arrow_drop_down),
                // Optional: customize dropdown
                dropdownColor: Theme.of(context).colorScheme.surface,
                // Map your theme items
                items: ThemeConfig.themes.map((themeName) {
                  return DropdownMenuItem<String>(
                    value: themeName,
                    child: Text(themeName),
                  );
                }).toList(),
                onChanged: (selectedName) {
                  if (selectedName != null) {
                    final newTheme = ThemeConfig.getTheme(selectedName);
                    themeProvider.setTheme(newTheme);
                    settingsProvider.updateTheme(selectedName);
                    context.read<SnackBarProvider>().showMessage('Theme updated to $selectedName');
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  /// ----------------------
  /// SECURITY / TIMEOUT
  /// ----------------------
  Widget _buildIdleTimeoutSection(SettingsProvider settingsProvider, ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Security / Timeout', style: theme.textTheme.titleLarge),
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
                        _temporaryIdleTimeout = value;
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
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final minutes = _temporaryIdleTimeout?.toInt() ?? 5;
                settingsProvider.updateIdleTimeout(minutes);
                context.read<SnackBarProvider>().showMessage('Idle timeout updated to $minutes minutes');
              },
              child: const Text('Save Timeout'),
            ),
          ],
        ),
      ),
    );
  }

  /// ----------------------
  /// PASSWORD SETTINGS
  /// ----------------------
  Widget _buildPasswordSettingsSection(SettingsProvider settingsProvider, ThemeData theme) {
    final minLen = settingsProvider.minLength;
    final maxLen = settingsProvider.maxLength;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Password Settings', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Add Delete button to password main view'),
              value: settingsProvider.showDeleteButtonMainView,
              onChanged: settingsProvider.toggleDeleteButtonMainView,
            ),

            SwitchListTile(
              title: const Text('Do Not Ask Before Deleting'),
              value: settingsProvider.skipDeleteConfirmation,
              onChanged: settingsProvider.toggleSkipDeleteConfirmation,
            ),

            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Define Password Generator Parameters'),
              value: settingsProvider.definePasswordGeneratorParams,
              onChanged: settingsProvider.toggleDefinePasswordGeneratorParams,
            ),

            if (settingsProvider.definePasswordGeneratorParams)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'The following fields are used for the password generator logic:',
                  style: theme.textTheme.bodyMedium,
                ),
              ),

            // Min / Max length + Exclude characters
            // Only enabled if "definePasswordGeneratorParams" is true
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: minLen.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Length',
                      border: OutlineInputBorder(),
                    ),
                    enabled: settingsProvider.definePasswordGeneratorParams,
                    onChanged: (value) {
                      final min = int.tryParse(value) ?? minLen;
                      settingsProvider.updatePasswordGeneratorSettings(
                        min,
                        settingsProvider.maxLength,
                        settingsProvider.excludeChars,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: maxLen.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Length',
                      border: OutlineInputBorder(),
                    ),
                    enabled: settingsProvider.definePasswordGeneratorParams,
                    onChanged: (value) {
                      final max = int.tryParse(value) ?? maxLen;
                      settingsProvider.updatePasswordGeneratorSettings(
                        settingsProvider.minLength,
                        max,
                        settingsProvider.excludeChars,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: settingsProvider.excludeChars,
              decoration: const InputDecoration(
                labelText: 'Exclude Characters',
                border: OutlineInputBorder(),
              ),
              enabled: settingsProvider.definePasswordGeneratorParams,
              onChanged: (value) {
                settingsProvider.updatePasswordGeneratorSettings(
                  settingsProvider.minLength,
                  settingsProvider.maxLength,
                  value,
                );
              },
            ),

            const SizedBox(height: 16),
            // 2) The "Auto-Fill" renamed to "Auto-Generate & Fill Password"
            SwitchListTile(
              title: const Text('Auto-Generate & Fill Password'),
              value: settingsProvider.autoGenerateAndFill,
              onChanged: settingsProvider.definePasswordGeneratorParams ? settingsProvider.toggleAutoGenerateAndFill : null,
            ),
          ],
        ),
      ),
    );
  }
}
