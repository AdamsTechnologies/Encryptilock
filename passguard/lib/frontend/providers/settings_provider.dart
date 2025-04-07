import 'package:flutter/material.dart';
import 'package:Encryptilock/backend/controllers/config_settings_controller.dart';

class SettingsProvider extends ChangeNotifier {
  final ConfigSettingsController configManager;

  String _theme = 'light';
  int _idleTimeout = 5; // Default 5 minutes

  int _minLength = 8;
  int _maxLength = 32;
  String _excludeChars = '';
  bool _autoFill = false;
  bool _showDeleteButton = false;
  bool _skipDeleteConfirmation = false;
  bool _showDeleteButtonMainView = false;
  bool _definePasswordGeneratorParams = false;
  bool _autoGenerateAndFill = false;
  bool _showHiddenPasswords = true;

  SettingsProvider(this.configManager);

  // --------------------------
  // GETTERS
  // --------------------------
  String get settingsTheme => _theme;
  int get idleTimeout => _idleTimeout;
  int get minLength => _minLength;
  int get maxLength => _maxLength;
  String get excludeChars => _excludeChars;
  bool get autoFill => _autoFill;
  bool get showDeleteButton => _showDeleteButton;
  bool get skipDeleteConfirmation => _skipDeleteConfirmation;
  bool get showDeleteButtonMainView => _showDeleteButtonMainView;
  bool get definePasswordGeneratorParams => _definePasswordGeneratorParams;
  bool get autoGenerateAndFill => _autoGenerateAndFill;
  bool get showHiddenPasswords => _showHiddenPasswords;

  // --------------------------
  // LOAD SETTINGS
  // --------------------------
  Future<void> loadSettings() async {
    _theme = await configManager.getSetting('theme') ?? 'light';
    _idleTimeout = int.tryParse(await configManager.getSetting('idle_timeout') ?? '5') ?? 5;
    _minLength = int.tryParse(await configManager.getSetting('min_length') ?? '8') ?? 8;
    _maxLength = int.tryParse(await configManager.getSetting('max_length') ?? '32') ?? 32;
    _excludeChars = await configManager.getSetting('exclude_chars') ?? '';
    _autoFill = (await configManager.getSetting('auto_fill') == 'true');
    _showDeleteButton = (await configManager.getSetting('show_delete_button') == 'true');
    _skipDeleteConfirmation = (await configManager.getSetting('skip_delete_confirmation') == 'true');
    _showDeleteButtonMainView = (await configManager.getSetting('show_delete_button_main_view') == 'true');
    _definePasswordGeneratorParams = (await configManager.getSetting('define_password_generator_params') == 'true');
    _autoGenerateAndFill = (await configManager.getSetting('auto_generate_and_fill') == 'true');
    _showHiddenPasswords = (await configManager.getSetting('show_hidden_passwords') == 'true');

    notifyListeners();
  }

  // --------------------------
  // UPDATE / SAVE SETTINGS
  // --------------------------
  Future<void> updateTheme(String newTheme) async {
    _theme = newTheme;
    await configManager.setSetting('theme', newTheme);
    notifyListeners();
  }

  Future<void> updateIdleTimeout(int minutes) async {
    _idleTimeout = minutes;
    await configManager.setSetting('idle_timeout', minutes.toString());
    notifyListeners();
  }

  Future<void> updatePasswordGeneratorSettings(int minLength, int maxLength, String excludeChars) async {
    _minLength = minLength;
    _maxLength = maxLength;
    _excludeChars = excludeChars;
    await configManager.setSetting('min_length', minLength.toString());
    await configManager.setSetting('max_length', maxLength.toString());
    await configManager.setSetting('exclude_chars', excludeChars);
    notifyListeners();
  }

  Future<void> toggleAutoFill(bool enabled) async {
    _autoFill = enabled;
    await configManager.setSetting('auto_fill', enabled.toString());
    notifyListeners();
  }

  Future<void> toggleShowDeleteButton(bool enabled) async {
    _showDeleteButton = enabled;
    await configManager.setSetting('show_delete_button', enabled.toString());
    notifyListeners();
  }

  Future<void> toggleSkipDeleteConfirmation(bool enabled) async {
    _skipDeleteConfirmation = enabled;
    await configManager.setSetting('skip_delete_confirmation', enabled.toString());
    notifyListeners();
  }

  Future<void> toggleDeleteButtonMainView(bool val) async {
    _showDeleteButtonMainView = val;
    await configManager.setSetting('show_delete_button_main_view', val.toString());
    notifyListeners();
  }

  Future<void> toggleShowHiddenPasswords(bool val) async {
    _showHiddenPasswords = val;
    await configManager.setSetting('show_hidden_passwords', val.toString());
    notifyListeners();
  }

  Future<void> toggleDefinePasswordGeneratorParams(bool val) async {
    _definePasswordGeneratorParams = val;
    await configManager.setSetting('define_password_generator_params', val.toString());
    notifyListeners();
  }

  Future<void> toggleAutoGenerateAndFill(bool val) async {
    _autoGenerateAndFill = val;
    await configManager.setSetting('auto_generate_and_fill', val.toString());
    notifyListeners();
  }
}
