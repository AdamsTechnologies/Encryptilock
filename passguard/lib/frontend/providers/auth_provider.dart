import 'package:flutter/material.dart';
import 'package:encryptilock/backend/devsec/encrypto.dart';
import 'package:encryptilock/backend/controllers/config_settings_controller.dart';
import 'package:encryptilock/backend/databaseManager/encrypted_database_manager.dart';
import 'package:encryptilock/frontend/providers/snackbar_provider.dart';
import 'package:encryptilock/backend/helpers/custom_exceptions.dart';
import 'package:encryptilock/backend/helpers/path_utils.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _username;
  EncryptedDatabaseManager? _encryptedDbManager;
  dynamic _inMemoryDb; // Replace with your in-memory database type

  final ConfigSettingsController configManager;
  late SnackBarProvider _snackBarProvider;

  AuthProvider({required this.configManager});

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get username => _username;
  dynamic get inMemoryDb => _inMemoryDb;

  void updateSnackBarProvider(SnackBarProvider snackBarProvider) {
    _snackBarProvider = snackBarProvider;
  }

  Future<void> shutdown() async {
    await configManager.close();
    notifyListeners();
  }

  // Login method
  Future<void> login(String username, String password) async {
    _snackBarProvider.showMessage('decrypting database');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Retrieve stored username and salt from config
      final storedUsername = await configManager.getHashedSetting('session_marker');
      final storedSalt = await configManager.getHashedSetting('session_ref');

      // Validate username
      if (storedUsername != null && storedUsername != username) {
        throw IncorrectUsernameException('Username does not match stored username.');
      }

      // Initialize EncryptedDatabaseManager with the retrieved salt
      final dbPath = await getLocalPath('s2.db');
      _encryptedDbManager = EncryptedDatabaseManager(
        dbPath: dbPath,
        password: password,
        providedSalt: storedSalt,
      );
      // Open the encrypted database
      _inMemoryDb = await _encryptedDbManager!.open();
      _username = username;

      // Set XOR key if its null
      if (configManager.xorKey == null) {
        configManager.setXorKey(_encryptedDbManager!.currentSalt);
      }

      final newSalt = _encryptedDbManager!.currentSalt;
      if (storedSalt == null) {
        // Store the raw salt first (no XOR obfuscation)
        await configManager.setHashedSetting('session_ref', newSalt);
      }

      // Update stored username if not already set
      if (storedUsername == null) {
        await configManager.setHashedSetting('session_marker', username);
      }

      _isLoggedIn = true;
      _snackBarProvider.showMessage('login successful');
    } catch (error) {
      // Handle login errors
      if (error.runtimeType.toString() == 'IncorrectUsernameException') _snackBarProvider.showMessage('invalid username');
      if (error.runtimeType.toString() == 'SecretBoxAuthenticationError') _snackBarProvider.showMessage('invalid password');
      _errorMessage = error.toString();
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout method
  Future<void> logout() async {
    _snackBarProvider.showMessage('cleaning up');
    _isLoading = true;
    notifyListeners();

    try {
      if (_encryptedDbManager != null && _inMemoryDb != null) {
        print("AuthProvider closing up the database and logging out.");
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
      _snackBarProvider.showMessage('logout successful');
    }
  }

  Encrypto? get encrypto => _encryptedDbManager?.encrypto;
}
