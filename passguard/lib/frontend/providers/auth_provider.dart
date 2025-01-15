import 'package:flutter/material.dart';
import 'package:passguard/backend/databaseManager/encrypted_database_manager.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _username;
  EncryptedDatabaseManager? _encryptedDbManager;
  dynamic _inMemoryDb; // Replace with your in-memory database type

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  dynamic get inMemoryDb => _inMemoryDb;

  void login(String username, dynamic inMemoryDb) {
    _isLoggedIn = true;
    _username = username;
    _inMemoryDb = inMemoryDb;
    notifyListeners();
  }

  Future<void> logout() async {
    if (_encryptedDbManager != null && _inMemoryDb != null) {
      await _encryptedDbManager!.close(_inMemoryDb);
    }
    _isLoggedIn = false;
    _username = null;
    _inMemoryDb = null;
    notifyListeners();
  }
}
