import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'package:passguard/frontend/providers/auth_provider.dart';
import 'package:passguard/backend/databaseManager/dart_sqlite.dart';
import 'package:passguard/backend/controllers/config_settings_controller.dart';
import 'package:passguard/backend/databaseManager/encrypted_database_manager.dart';

import 'package:passguard/backend/devsec/deterministic_hash.dart';

/*
class LoginScreen extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  LoginScreen({Key? key}) : super(key: key);

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
                onPressed: () async {
                  final username = hashObject(usernameController.text); // irreversably hash
                  final password = hashObject(passwordController.text);

                  // Retrieve config settings
                  final settingsDb = DartSqlite(dbFile: 'configsettings.db');
                  settingsDb.open();
                  final configManager = ConfigSettingsController(settingsDb);

                  // Get or create the salt
                  final salt = await configManager.getSetting('salt'); // 

                  // Initialize EncryptedDatabaseManager
                  final encryptedDbManager = EncryptedDatabaseManager(
                    dbPath: 'datastore.db',
                    password: password,
                    providedSalt: salt,
                  );

                  // Decrypt the database
                  final inMemoryDb = await encryptedDbManager.open();
                  
                  await configManager.setSetting('salt', encryptedDbManager.currentSalt);
                  
                  // Login and pass the in-memory DB
                  context.read<AuthProvider>().login(username, inMemoryDb);

                  // Close settings DB after use
                  settingsDb.close();
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
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
