import 'package:flutter/material.dart';
import 'package:passguard/backend/controllers/config_settings_controller.dart';

class SettingsProvider extends ChangeNotifier {
  final ConfigSettingsController configManager;

  String _theme = 'light';
  int _idleTimeout = 5; // Default 5 minutes

  String _landingPage = 'dashboard';
  int _minLength = 8;
  int _maxLength = 32;
  String _excludeChars = '';
  bool _autoFill = false;
  bool _showDeleteButton = false;
  bool _skipDeleteConfirmation = false;

  // NEW SETTINGS
  bool _showDeleteButtonMainView = false;
  bool _definePasswordGeneratorParams = false;
  bool _autoGenerateAndFill = false;

  SettingsProvider(this.configManager);

  // --------------------------
  // GETTERS
  // --------------------------
  String get settingsTheme => _theme;
  int get idleTimeout => _idleTimeout;
  String get landingPage => _landingPage;
  int get minLength => _minLength;
  int get maxLength => _maxLength;
  String get excludeChars => _excludeChars;
  bool get autoFill => _autoFill;
  bool get showDeleteButton => _showDeleteButton;
  bool get skipDeleteConfirmation => _skipDeleteConfirmation;

  // NEW GETTERS
  bool get showDeleteButtonMainView => _showDeleteButtonMainView;
  bool get definePasswordGeneratorParams => _definePasswordGeneratorParams;
  bool get autoGenerateAndFill => _autoGenerateAndFill;

  // --------------------------
  // LOAD SETTINGS
  // --------------------------
  Future<void> loadSettings() async {
    _theme = await configManager.getSetting('theme') ?? 'light';
    _idleTimeout = int.tryParse(await configManager.getSetting('idle_timeout') ?? '5') ?? 5;
    _landingPage = await configManager.getSetting('landing_page') ?? 'dashboard';
    _minLength = int.tryParse(await configManager.getSetting('min_length') ?? '8') ?? 8;
    _maxLength = int.tryParse(await configManager.getSetting('max_length') ?? '32') ?? 32;
    _excludeChars = await configManager.getSetting('exclude_chars') ?? '';
    _autoFill = (await configManager.getSetting('auto_fill') == 'true');
    _showDeleteButton = (await configManager.getSetting('show_delete_button') == 'true');
    _skipDeleteConfirmation = (await configManager.getSetting('skip_delete_confirmation') == 'true');

    // NEW SETTINGS
    _showDeleteButtonMainView = (await configManager.getSetting('show_delete_button_main_view') == 'true');
    _definePasswordGeneratorParams = (await configManager.getSetting('define_password_generator_params') == 'true');
    _autoGenerateAndFill = (await configManager.getSetting('auto_generate_and_fill') == 'true');

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

  Future<void> updateLandingPage(String page) async {
    _landingPage = page;
    await configManager.setSetting('landing_page', page);
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

  // --------------------------
  // NEW TOGGLE METHODS
  // --------------------------
  Future<void> toggleDeleteButtonMainView(bool val) async {
    _showDeleteButtonMainView = val;
    await configManager.setSetting('show_delete_button_main_view', val.toString());
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

// 2025-03-06
// import 'package:flutter/material.dart';
// import 'package:passguard/backend/controllers/config_settings_controller.dart';

// class SettingsProvider extends ChangeNotifier {
//   final ConfigSettingsController configManager;

//   String _theme = 'light';
//   int _idleTimeout = 5; // Default 5 minutes

//   String _landingPage = 'dashboard';
//   int _minLength = 8;
//   int _maxLength = 32;
//   String _excludeChars = '';
//   bool _autoFill = false;
//   bool _showDeleteButton = false;
//   bool _skipDeleteConfirmation = false;

//   SettingsProvider(this.configManager);

//   String get settingsTheme => _theme;
//   int get idleTimeout => _idleTimeout;
//   String get landingPage => _landingPage;
//   int get minLength => _minLength;
//   int get maxLength => _maxLength;
//   String get excludeChars => _excludeChars;
//   bool get autoFill => _autoFill;
//   bool get showDeleteButton => _showDeleteButton;
//   bool get skipDeleteConfirmation => _skipDeleteConfirmation;

//   Future<void> loadSettings() async {
//     _theme = await configManager.getSetting('theme') ?? 'light';
//     _idleTimeout = int.tryParse(await configManager.getSetting('idle_timeout') ?? '5') ?? 5;
//     _landingPage = await configManager.getSetting('landing_page') ?? 'dashboard';
//     _minLength = int.tryParse(await configManager.getSetting('min_length') ?? '8') ?? 8;
//     _maxLength = int.tryParse(await configManager.getSetting('max_length') ?? '32') ?? 32;
//     _excludeChars = await configManager.getSetting('exclude_chars') ?? '';
//     _autoFill = (await configManager.getSetting('auto_fill') == 'true');
//     _showDeleteButton = (await configManager.getSetting('show_delete_button') == 'true');
//     _skipDeleteConfirmation = (await configManager.getSetting('skip_delete_confirmation') == 'true');
//     notifyListeners();
//   }

//   Future<void> updateTheme(String newTheme) async {
//     _theme = newTheme;
//     await configManager.setSetting('theme', newTheme);
//     notifyListeners();
//   }

//   Future<void> updateIdleTimeout(int minutes) async {
//     _idleTimeout = minutes;
//     await configManager.setSetting('idle_timeout', minutes.toString());
//     notifyListeners();
//   }

//   Future<void> updateLandingPage(String page) async {
//     _landingPage = page;
//     await configManager.setSetting('landing_page', page);
//     notifyListeners();
//   }

//   Future<void> updatePasswordGeneratorSettings(int minLength, int maxLength, String excludeChars) async {
//     _minLength = minLength;
//     _maxLength = maxLength;
//     _excludeChars = excludeChars;
//     await configManager.setSetting('min_length', minLength.toString());
//     await configManager.setSetting('max_length', maxLength.toString());
//     await configManager.setSetting('exclude_chars', excludeChars);
//     notifyListeners();
//   }

//   Future<void> toggleAutoFill(bool enabled) async {
//     _autoFill = enabled;
//     await configManager.setSetting('auto_fill', enabled.toString());
//     notifyListeners();
//   }

//   Future<void> toggleShowDeleteButton(bool enabled) async {
//     _showDeleteButton = enabled;
//     await configManager.setSetting('show_delete_button', enabled.toString());
//     notifyListeners();
//   }

//   Future<void> toggleSkipDeleteConfirmation(bool enabled) async {
//     _skipDeleteConfirmation = enabled;
//     await configManager.setSetting('skip_delete_confirmation', enabled.toString());
//     notifyListeners();
//   }
// }
