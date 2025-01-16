import 'package:flutter/material.dart';
import 'package:passguard/backend/databaseManager/encrypted_database_manager.dart';
import 'package:passguard/backend/controllers/config_settings_controller.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _username;
  EncryptedDatabaseManager? _encryptedDbManager;
  dynamic _inMemoryDb; // Replace with your in-memory database type

  final ConfigSettingsController configManager;

  AuthProvider({required this.configManager});

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get username => _username;
  dynamic get inMemoryDb => _inMemoryDb;

  // Login method
  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Retrieve stored username and salt from config
      final storedUsername = await configManager.getSetting('username');
      final storedSalt = await configManager.getSetting('salt');

      // Validate username
      if (storedUsername != null && storedUsername != username) {
        throw Exception('Username does not match stored username.');
      }

      // Initialize EncryptedDatabaseManager with the retrieved salt
      _encryptedDbManager = EncryptedDatabaseManager(
        dbPath: 'datastore.db', // Update with actual path
        password: password,
        providedSalt: storedSalt,
      );

      // Open the encrypted database
      _inMemoryDb = await _encryptedDbManager!.open();

      // Update login state
      _isLoggedIn = true;
      _username = username;

      // Check and update the salt if it has changed
      final newSalt = _encryptedDbManager!.currentSalt;
      if (storedSalt != newSalt) {
        await configManager.setSetting('salt', newSalt);
      }

      // Update stored username if not already set
      if (storedUsername == null) {
        await configManager.setSetting('username', username);
      }
    } catch (error) {
      // Handle login errors
      _errorMessage = error.toString();
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout method
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_encryptedDbManager != null && _inMemoryDb != null) {
        await _encryptedDbManager!.close(_inMemoryDb);
      }
    } catch (error) {
      _errorMessage = "Error during logout: ${error.toString()}";
    } finally {
      _isLoggedIn = false;
      _username = null;
      _inMemoryDb = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}
