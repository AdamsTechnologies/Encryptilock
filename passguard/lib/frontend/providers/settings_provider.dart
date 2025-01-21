import 'package:flutter/material.dart';
import 'package:passguard/backend/controllers/config_settings_controller.dart';


class SettingsProvider extends ChangeNotifier {
  final ConfigSettingsController configManager;

  String _theme = 'light';
  int _idleTimeout = 5; // Default 5 minutes

  String get settingsTheme => _theme;
  int get idleTimeout => _idleTimeout;

  SettingsProvider( // TODO review - This provider should probably just load all settings directly from the configsettings manager, not be passed in like this
    this.configManager, {
    required String initialTheme,
    required int initialIdleTimeout,
  }) {
    // TODO ; flutter syntax to check if NewTheme not in configThemes list.
    // TODO TODO, in future allow users to create their own themes. but not now.
    print('Theme stored in db: $initialTheme');
    _theme = initialTheme;
    _idleTimeout = initialIdleTimeout;
  }

  /// Updates the theme and persists it in the config database
  Future<void> updateTheme(String newTheme) async {
    // TODO ; flutter syntax to check if NewTheme not in configThemes list.
    // TODO TODO, in future allow users to create their own themes. but not now.
    _theme = newTheme;
    await configManager.setSetting('theme', newTheme);
    notifyListeners();
  }

  /// Updates the idle timeout and persists it in the config database
  Future<void> updateIdleTimeout(int minutes) async {
    _idleTimeout = minutes;
    await configManager.setSetting('idle_timeout', minutes.toString());
    notifyListeners();
  }
}
