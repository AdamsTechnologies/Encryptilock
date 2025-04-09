import 'package:flutter/material.dart';
import 'auth_provider.dart'; // For database connection state
import 'package:encryptilock/backend/controllers/password_controller.dart';

class PasswordProvider extends ChangeNotifier {
  AuthProvider? _authProvider;
  PasswordController? _passwordController;

  // State properties
  List<Map<String, dynamic>> _passwords = [];
  String? _selectedPasswordId; // Active password
  String _mode = 'list'; // 'list' | 'detail' | 'create' | 'edit'
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic>? get selectedPassword {
    if (_selectedPasswordId == null) return null;
    return _passwords.firstWhere(
      (pw) => pw['id'] == _selectedPasswordId,
      orElse: () => {},
    );
  }

  List<Map<String, dynamic>> get passwords => _passwords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get mode => _mode;

  // Setters and Methods
  void setMode(String newMode) {
    _mode = newMode;
    notifyListeners();
  }

  /// Updates the AuthProvider reference and initializes the PasswordController if logged in.
  void updateAuthProvider(AuthProvider newAuth) {
    // final hadAuth = _authProvider;
    _authProvider = newAuth;

    if (_authProvider!.isLoggedIn && !_authProvider!.isLoading) {
      _initializeController();
    } else if (!_authProvider!.isLoggedIn) {
      _passwordController = null;
      _passwords.clear();
      _selectedPasswordId = null;
      _mode = 'list';
      notifyListeners();
    }
  }

  /// Initializes the PasswordController and fetches passwords.
  Future<void> _initializeController() async {
    if (_authProvider == null) {
      _errorMessage = 'No AuthProvider available.';

      notifyListeners();
      return;
    }

    if (_authProvider!.isLoggedIn && _authProvider!.inMemoryDb != null) {
      try {
        _passwordController = PasswordController(
          dbController: _authProvider!.inMemoryDb!,
          encrypto: _authProvider!.encrypto!,
          schema: {
            "id": "TEXT PRIMARY KEY",
            "username": "TEXT",
            "password": "TEXT",
            "service": "TEXT",
            "servicetype": "TEXT",
            "url": "TEXT NULL",
            "notes": "TEXT NULL",
            "isactive": "INTEGER",
            "createdt": "datetime",
            "updatedt": "datetime",
          },
        );
        await _passwordController!.init();

        await fetchPasswords(); // Load initial data
      } catch (e) {
        _errorMessage = 'Error initializing PasswordProvider: $e';

        notifyListeners();
      }
    } else {
      _errorMessage = 'No database connection available.';

      notifyListeners();
    }
  }

  Future<void> fetchPasswords() async {
    if (!_validateDbConnection()) return;

    _setLoading(true);
    try {
      _passwords = await _passwordController!.getAllRecords(); // decryptFields: ['password']

      _errorMessage = null;
      notifyListeners(); // Notify listeners after fetching
    } catch (e) {
      _errorMessage = 'Error fetching passwords: $e';

      notifyListeners(); // Notify listeners about the error
    } finally {
      _setLoading(false);
    }
  }

  /// Adds or updates a password entry.
  /// [passwordChanged] indicates whether the password was modified.
  Future<void> addOrUpdatePassword(Map<String, dynamic> data, {bool passwordChanged = false}) async {
    if (!_validateDbConnection()) return;

    _setLoading(true);

    try {
      String upsertedId = await _passwordController!.upsertRecord(
        id: data['id'],
        username: data['username'],
        password: data['password'],
        service: data['service'],
        servicetype: data['servicetype'],
        url: data['url'],
        notes: data['notes'],
        isactive: data['isactive'] ?? 1,
        createdt: data['createdt'],
        passwordChanged: passwordChanged, // Pass the flag here
      );

      await fetchPasswords();

      if (_mode == 'create' || _mode == 'edit') {
        selectPasswordId(upsertedId);
      }
    } catch (e) {
      _errorMessage = 'Error saving password: $e';

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a password entry by ID.
  Future<void> deletePassword(String id) async {
    if (!_validateDbConnection()) return;

    _setLoading(true);
    try {
      await _passwordController!.removeRecord(id);
      _passwords.removeWhere((record) => record['id'] == id);
      _selectedPasswordId = null;
      _mode = 'list';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting password: $e';

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Decrypts the given encrypted password.
  Future<String> decryptPassword(String encryptedPassword) async {
    String decryptedPassword = await _passwordController!.encrypto.decrypto(encryptedPassword);

    return decryptedPassword;
  }

  void resetToCreateMode() {
    _selectedPasswordId = null;
    _mode = 'create';
    notifyListeners();
  }

  /// Selects a password by ID and updates the mode accordingly.
  void selectPasswordId(String? id) {
    _selectedPasswordId = id;
    _mode = (id != null) ? 'detail' : 'list';
    notifyListeners();
  }

  /// Clears all stored data.
  void clearMemory() {
    _passwords = [];
    _selectedPasswordId = null;
    _mode = 'list';
    notifyListeners();
  }

  /// Validates the database connection.
  bool _validateDbConnection() {
    if (_authProvider == null || !_authProvider!.isLoggedIn || _authProvider!.inMemoryDb == null) {
      _errorMessage = 'No active database connection.';

      notifyListeners();
      return false;
    }
    return true;
  }

  /// Sets the loading state.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
