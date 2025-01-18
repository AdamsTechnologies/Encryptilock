import 'package:flutter/material.dart';
import 'auth_provider.dart'; // For database connection state
import 'package:passguard/backend/controllers/password_controller.dart';

class PasswordProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  late PasswordController _passwordController;

  // State properties
  List<Map<String, dynamic>> _passwords = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Constructor
  PasswordProvider({required this.authProvider}) {
    _initializeController();
  }

  // Getters
  List<Map<String, dynamic>> get passwords => _passwords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize the PasswordController and load initial data
  Future<void> _initializeController() async {
    if (authProvider.isLoggedIn && authProvider.inMemoryDb != null) {
      try {
        _passwordController = PasswordController(
          dbController: authProvider.inMemoryDb,
          encrypto: authProvider.encrypto!,
          schema: {
            "id": "nvarchar(50) PRIMARY KEY",
            "username": "nvarchar(256)",
            "password": "nvarchar(256)",
            "service": "nvarchar(1000)",
            "servicetype": "nvarchar(1000)",
            "isactive": "bit",
            "url": "nvarchar(MAX) NULL",
            "dt": "datetime",
          },
        );

        await _passwordController.init();
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

  /// Fetch all passwords from the database
  Future<void> fetchPasswords() async {
    if (!_validateDbConnection()) return;

    _setLoading(true);
    try {
      _passwords =
          await _passwordController.getAllRecords(decryptFields: ['password']);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error fetching passwords: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Add or update a password
  Future<void> addOrUpdatePassword(Map<String, dynamic> data) async {
    if (!_validateDbConnection()) return;

    _setLoading(true);
    try {
      await _passwordController.upsertRecord(
        id: data['id'],
        username: data['username'],
        password: data['password'],
        service: data['service'],
        servicetype: data['servicetype'],
        url: data['url'],
        isactive: data['isactive'] ?? true,
      );
      await fetchPasswords();
    } catch (e) {
      _errorMessage = 'Error saving password: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a password by its ID
  Future<void> deletePassword(String id) async {
    if (!_validateDbConnection()) return;

    _setLoading(true);
    try {
      await _passwordController.removeRecord(id);
      _passwords.removeWhere((record) => record['id'] == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting password: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Clear all passwords from memory
  void clearMemory() {
    _passwords = [];
    notifyListeners();
  }

  /// Validate the database connection
  bool _validateDbConnection() {
    if (!authProvider.isLoggedIn || authProvider.inMemoryDb == null) {
      _errorMessage = 'No active database connection.';
      notifyListeners();
      return false;
    }
    return true;
  }

  /// Set the loading state and notify listeners
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
