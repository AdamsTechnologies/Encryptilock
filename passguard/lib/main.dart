import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:encryptilock/frontend/app_main.dart';
import 'package:encryptilock/frontend/screens/login_screen.dart';
import 'package:encryptilock/frontend/providers/auth_provider.dart';
import 'package:encryptilock/backend/databaseManager/dart_sqlite.dart';
import 'package:encryptilock/frontend/providers/settings_provider.dart';
import 'package:encryptilock/backend/controllers/config_settings_controller.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite and settings manager
  final settingsDb = DartSqlite(dbFile: 'configsettings.db');
  settingsDb.open();
  final configManager = ConfigSettingsController(settingsDb);

  // Load initial settings
  final initialTheme = await configManager.getSetting('theme') ?? 'light';
  final initialIdleTimeout = int.tryParse(await configManager.getSetting('idle_timeout') ?? '5') ?? 5;

  runApp(MyApp(
    settingsDb: settingsDb,
    configManager: configManager,
    initialTheme: initialTheme,
    initialIdleTimeout: initialIdleTimeout,
  ));
}

class MyApp extends StatelessWidget {
  final DartSqlite settingsDb;
  final ConfigSettingsController configManager;
  final String initialTheme;
  final int initialIdleTimeout;

  const MyApp({
    Key? key,
    required this.settingsDb,
    required this.configManager,
    required this.initialTheme,
    required this.initialIdleTimeout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            configManager, // Corrected argument
            initialTheme: initialTheme,
            initialIdleTimeout: initialIdleTimeout,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'PassGuard',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return auth.isLoggedIn
                    ? MainApp() // Remove const for dynamic widget
                    : LoginScreen(); // Remove const for dynamic widget
              },
            ),
          );
        },
      ),
    );
  }
}