import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:encryptilock/frontend/providers/auth_provider.dart';
import 'package:encryptilock/backend/databaseManager/dart_sqlite.dart';
import 'package:encryptilock/backend/controllers/config_settings_controller.dart';
import 'package:encryptilock/backend/databaseManager/encrypted_database_manager.dart';

import 'package:encryptilock/backend/devsec/deterministic_hash.dart';

/*
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleLogin,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final username = hashObject(usernameController.text);
    final password = hashObject(passwordController.text);

    // Retrieve config settings
    final settingsDb = DartSqlite(dbFile: 'configsettings.db');
    settingsDb.open();
    final configManager = ConfigSettingsController(settingsDb);

    try {
      // Get or create the salt
      final salt = await configManager.getSetting('salt');

      // Initialize EncryptedDatabaseManager
      final encryptedDbManager = EncryptedDatabaseManager(
        dbPath: 'datastore.db',
        password: password,
        providedSalt: salt,
      );

      // Decrypt the database
      final inMemoryDb = await encryptedDbManager.open();
      await configManager.setSetting('salt', encryptedDbManager.currentSalt);
      // Ensure the widget is still mounted before accessing context
      if (!mounted) return;

      // Login and pass the in-memory DB
      context.read<AuthProvider>().login(username, inMemoryDb);
    } catch (e) {
      // Handle errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      print("Login Screen closing the settingsDb.");
      settingsDb.close();
    }
  }
}
*/

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isNewUser = false;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    final settingsDb = DartSqlite(dbFile: 'configsettings.db');
    settingsDb.open();
    final configManager = ConfigSettingsController(settingsDb);

    final username = await configManager.getSetting('username');
    final isRegistered = await configManager.getSetting('is_registered') ?? '0';

    if (username == null || isRegistered == '0') {
      setState(() {
        isNewUser = true;
      });
    }

    settingsDb.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400), // Restrict width
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                if (isNewUser)
                  TextField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _handleLoginOrRegister,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                  ),
                  child: Text(isNewUser ? 'Register' : 'Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _handleLoginOrRegister() async {
    // Retrieve config settings
    final settingsDb = DartSqlite(dbFile: 'configsettings.db');
    settingsDb.open();
    final configManager = ConfigSettingsController(settingsDb);
    try {
      final username = hashObject(usernameController.text);
      final password = hashObject(passwordController.text);

      if (isNewUser) {
        final confirmPassword = hashObject(confirmPasswordController.text);
        if (password != confirmPassword) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwords do not match!')),
          );
          await configManager.setSetting('username', username);
          return;
        }
      }

      await _handleUsername(username, configManager); // sets/validates username input.
      // Get or create the salt
      final salt = await configManager.getSetting('salt');

      // Initialize EncryptedDatabaseManager
      final encryptedDbManager = EncryptedDatabaseManager(
        dbPath: 'datastore.db',
        password: password,
        providedSalt: salt,
      );

      // Decrypt the database
      final inMemoryDb = await encryptedDbManager.open();
      await configManager.setSetting('salt', encryptedDbManager.currentSalt);
      // Ensure the widget is still mounted before accessing context
      if (!mounted) return;
      // Login and pass the in-memory DB
      context.read<AuthProvider>().login(username, inMemoryDb);
    } catch (e) {
      // Handle errors gracefully
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      print("Login Screen closing the settingsDb.");
      settingsDb.close();
    }
  }
  Future<void> _handleUsername(String username, ConfigSettingsController configManager) async {
    final storedUsername = await configManager.getSetting('username');
      if (storedUsername == null) {
        await configManager.setSetting('username', username);
        return;
      } else if (storedUsername != username) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid username, check your spelling.')),
          );
      }
      return;
  }
}