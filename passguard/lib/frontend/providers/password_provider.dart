import 'package:flutter/material.dart';
import 'auth_provider.dart'; // For database connection state
import 'package:passguard/backend/controllers/password_controller.dart';

class PasswordProvider extends ChangeNotifier {
  AuthProvider? _authProvider;
  PasswordController? _passwordController;

  // State properties
  List<Map<String, dynamic>> _passwords = [];
  String? _selectedPasswordId; // active password
  bool _isLoading = false;
  String? _errorMessage;

  // Expose the selected password
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

  // --------------------------------------------------------------------------
  // NEW: This method is called by main.dart's ProxyProvider update()
  // --------------------------------------------------------------------------
  void updateAuthProvider(AuthProvider newAuth) {
    // If it's a new auth reference or login state changed, re-initialize
    final hadAuth = _authProvider;
    _authProvider = newAuth;

    // If the user just logged in (or if references changed), re-initialize
    if (_authProvider!.isLoggedIn && hadAuth?.isLoggedIn != _authProvider!.isLoggedIn) {
      _initializeController();
    }
    // If user just logged out, clear memory
    else if (!_authProvider!.isLoggedIn) {
      _passwordController = null;
      _passwords.clear();
      _selectedPasswordId = null;
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // Core logic
  // --------------------------------------------------------------------------
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
      _passwords = await _passwordController!.getAllRecords();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error fetching passwords: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addOrUpdatePassword(Map<String, dynamic> data) async {
    if (!_validateDbConnection()) return;

    _setLoading(true);
    try {
      await _passwordController!.upsertRecord(
        id: data['id'],
        username: data['username'],
        password: data['password'],
        service: data['service'],
        servicetype: data['servicetype'],
        url: data['url'],
        notes: data['notes'],
        isactive: data['isactive'] ?? true,
      );
      await fetchPasswords();
    } catch (e) {
      _errorMessage = 'Error saving password: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePassword(String id) async {
    if (!_validateDbConnection()) return;

    _setLoading(true);
    try {
      await _passwordController!.removeRecord(id);
      _passwords.removeWhere((record) => record['id'] == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting password: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<String> decryptPassword(String encryptedPassword) async {
    return await _passwordController!.encrypto.decrypto(encryptedPassword);
  }

  void clearMemory() {
    _passwords = [];
    _selectedPasswordId = null;
    notifyListeners();
  }

  bool _validateDbConnection() {
    if (_authProvider == null || !_authProvider!.isLoggedIn || _authProvider!.inMemoryDb == null) {
      _errorMessage = 'No active database connection.';
      notifyListeners();
      return false;
    }
    return true;
  }

  void selectPasswordId(String? id) {
    _selectedPasswordId = id;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}


// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:passguard/backend/controllers/password_controller.dart';

// class PasswordProvider extends ChangeNotifier {
//   final PasswordController passwordController;

//   List<Map<String, dynamic>> _passwords = [];
//   bool _isLoading = false;
//   String? _errorMessage;

//   List<Map<String, dynamic>> get passwords => _passwords;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;

//   PasswordProvider({required this.passwordController});

//   /// Initialize the provider, fetch passwords from the database
//   Future<void> initialize() async {
//     _setLoading(true);
//     try {
//       _passwords = await passwordController.getAllRecords(decryptFields: ['password']);
//       _errorMessage = null;
//     } catch (e) {
//       _errorMessage = 'Failed to load passwords: $e';
//     } finally {
//       _setLoading(false);
//     }
//   }

//   /// Fetch passwords (refresh the list)
//   Future<void> fetchPasswords() async {
//     _setLoading(true);
//     try {
//       _passwords = await passwordController.getAllRecords(decryptFields: ['password']);
//       _errorMessage = null;
//     } catch (e) {
//       _errorMessage = 'Error fetching passwords: $e';
//     } finally {
//       _setLoading(false);
//     }
//   }

//   /// Add or update a password record
//   Future<void> addOrUpdatePassword(Map<String, dynamic> data) async { // TODO Handle notes + createdDate and updatedDate
//     try { 
//       await passwordController.upsertRecord(
//         id: data['id'],
//         username: data['username'],
//         password: data['password'],
//         service: data['service'],
//         servicetype: data['servicetype'],
//         url: data['url'],
//         isactive: data['isactive'] ?? true,
//       );

//       // Refresh or update the local list
//       await fetchPasswords();
//     } catch (e) {
//       _errorMessage = 'Error saving password: $e';
//       notifyListeners();
//     }
//   }

//   /// Delete a password record by its ID
//   Future<void> deletePassword(String id) async {
//     try {
//       await passwordController.removeRecord(id);

//       // Remove from local list
//       _passwords.removeWhere((record) => record['id'] == id);
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Error deleting password: $e';
//       notifyListeners();
//     }
//   }

//   /// Internal utility to set loading state
//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }
// }
