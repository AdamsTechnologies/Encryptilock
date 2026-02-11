import 'package:flutter/material.dart';
import 'package:encryptilock/backend/controllers/config_settings_controller.dart';

class SettingsProvider extends ChangeNotifier {
  final ConfigSettingsController configManager;

  String _theme = 'Paper';
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
  bool _showFactoryReset = true;
  Set<String> _categoryFilters = {};
  bool _clearFiltersOnLogout = false;

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
  bool get showFactoryReset => _showFactoryReset;
  Set<String> get categoryFilters => _categoryFilters;
  bool get isAllCategoriesSelected => _categoryFilters.isEmpty;
  bool get clearFiltersOnLogout => _clearFiltersOnLogout;

  Future<void> shutdown() async {
    await configManager.close();
    notifyListeners();
  }

  // --------------------------
  // LOAD SETTINGS
  // --------------------------
  Future<void> loadSettings() async {
    // TODO 2025-04-15 future improvement: get all settings in 1 call instead of a bunch of individual calls; not too impactful now but will be as we expand settings.
    _theme = await configManager.getSetting('theme') ?? 'Light'; // default 'Light'
    _idleTimeout = int.tryParse(await configManager.getSetting('idle_timeout') ?? '5') ?? 5; // default 5
    _minLength = int.tryParse(await configManager.getSetting('min_length') ?? '8') ?? 8; // default 8
    _maxLength = int.tryParse(await configManager.getSetting('max_length') ?? '32') ?? 32; // default 32
    _excludeChars = await configManager.getSetting('exclude_chars') ?? ''; // default ''
    _autoFill = (await configManager.getSetting('auto_fill') == 'true'); // default false
    _showDeleteButton = (await configManager.getSetting('show_delete_button') == 'true'); // default false
    _skipDeleteConfirmation = (await configManager.getSetting('skip_delete_confirmation') == 'true'); // default false
    _showDeleteButtonMainView = (await configManager.getSetting('show_delete_button_main_view') == 'true'); // default false
    _definePasswordGeneratorParams = (await configManager.getSetting('define_password_generator_params') == 'true'); // default false
    _autoGenerateAndFill = (await configManager.getSetting('auto_generate_and_fill') == 'true'); // default false
    _showHiddenPasswords = (await configManager.getSetting('show_hidden_passwords') == 'true'); // default false
    _showFactoryReset = (await configManager.getHashedSetting('show_factory_reset') != 'false'); //default true
    final savedFilters = await configManager.getSetting('category_filters');
    _categoryFilters = savedFilters?.isNotEmpty == true ? savedFilters!.split('|').toSet() : {};
    _clearFiltersOnLogout = (await configManager.getSetting('clear_filters_on_logout') == 'true');
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

  Future<void> toggleFactoryResetDisplay(bool val) async {
    _showFactoryReset = val;
    //hashing instead of XorObfuscating because we access this at login, before a salt is set.
    await configManager.setHashedSetting('show_factory_reset', val.toString().toLowerCase());
    notifyListeners();
  }

  Future<void> setCategoryFilters(Set<String> newFilters) async {
    _categoryFilters = newFilters;
    await configManager.setSetting('category_filters', newFilters.join('|'));
    notifyListeners();
  }

  Future<void> clearCategoryFilters() async {
    _categoryFilters = {};
    await configManager.setSetting('category_filters', '');
    notifyListeners();
  }

  Future<void> toggleClearFiltersOnLogout(bool enabled) async {
    _clearFiltersOnLogout = enabled;
    await configManager.setSetting('clear_filters_on_logout', enabled.toString());
    notifyListeners();
  }
}
