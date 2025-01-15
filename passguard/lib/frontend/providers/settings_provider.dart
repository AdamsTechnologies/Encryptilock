import 'package:flutter/material.dart';
import 'package:encryptilock/backend/controllers/config_settings_controller.dart';


class SettingsProvider extends ChangeNotifier {
  final ConfigSettingsController configManager;

  bool _isDarkMode = false;
  int _idleTimeout = 5; // Default 5 minutes

  bool get isDarkMode => _isDarkMode;
  int get idleTimeout => _idleTimeout;

  SettingsProvider(
    this.configManager, {
    required String initialTheme,
    required int initialIdleTimeout,
  }) {
    _isDarkMode = initialTheme == 'dark';
    _idleTimeout = initialIdleTimeout;
  }

  /// Updates the theme and persists it in the config database
  Future<void> updateTheme(bool isDark) async {
    _isDarkMode = isDark;
    await configManager.setSetting('theme', isDark ? 'dark' : 'light');
    notifyListeners();
  }

  /// Updates the idle timeout and persists it in the config database
  Future<void> updateIdleTimeout(int minutes) async {
    _idleTimeout = minutes;
    await configManager.setSetting('idle_timeout', minutes.toString());
    notifyListeners();
  }
}
