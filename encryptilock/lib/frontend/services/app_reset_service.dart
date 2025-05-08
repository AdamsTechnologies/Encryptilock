import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:encryptilock/backend/databaseManager/dart_sqlite.dart';
// import 'package:encryptilock/backend/databaseManager/database_abstraction.dart';
import 'package:encryptilock/backend/helpers/encryptilock_database_factory.dart';

import 'package:encryptilock/backend/controllers/config_settings_controller.dart';
import 'package:encryptilock/frontend/providers/auth_provider.dart';
import 'package:encryptilock/frontend/providers/settings_provider.dart';
import 'package:encryptilock/frontend/providers/theme_provider.dart';
import 'package:encryptilock/frontend/providers/snackbar_provider.dart';
import 'package:encryptilock/frontend/providers/password_provider.dart';
import 'package:encryptilock/frontend/providers/document_provider.dart';
import 'package:encryptilock/frontend/services/idle_timeout_service.dart';
import 'package:encryptilock/backend/helpers/path_utils.dart';
import 'package:encryptilock/frontend/theme/theme_config.dart';
import 'package:encryptilock/main.dart';

class ResettingApp extends StatelessWidget {
  const ResettingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Conducting Factory Reset..."),
        ),
      ),
    );
  }
}

class AppResetService {
  static Future<void> resetToRegister({
    required BuildContext context,
    required ConfigSettingsController configManager,
  }) async {
    runApp(const ResettingApp());
    await Future.delayed(const Duration(milliseconds: 300));

    configManager.factoryReset();
    configManager.close();

    final vaultPath = await getLocalPath('s2.db');
    final vaultFile = File(vaultPath);
    try {
      if (await vaultFile.exists()) {
        await vaultFile.delete();
      }
    } catch (e) {
      debugPrint('Vault file deletion error.');
    }

    final configPath = await getLocalPath('s1.db');
    // final newConn = DartSqlite(dbFile: configPath);
    final newConn = await createEncryptilockDatabase(configPath);
    await newConn.open();
    final newConfigManager = await ConfigSettingsController.init(newConn);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SnackBarProvider()),
          ChangeNotifierProxyProvider<SnackBarProvider, AuthProvider>(
            create: (_) => AuthProvider(configManager: newConfigManager),
            update: (_, snackBarProvider, authProvider) => authProvider!..updateSnackBarProvider(snackBarProvider),
          ),
          ChangeNotifierProvider(create: (_) => SettingsProvider(newConfigManager)..loadSettings()),
          ChangeNotifierProxyProvider<SettingsProvider, ThemeProvider>(
            create: (context) {
              final settings = Provider.of<SettingsProvider>(context, listen: false);
              final themeData = ThemeConfig.getTheme(settings.settingsTheme);
              return ThemeProvider(themeData);
            },
            update: (context, settings, themeProvider) {
              themeProvider?.setTheme(ThemeConfig.getTheme(settings.settingsTheme));
              return themeProvider!;
            },
          ),
          ChangeNotifierProxyProvider2<AuthProvider, SettingsProvider, IdleTimeoutService>(
            create: (_) => IdleTimeoutService(),
            update: (_, auth, settings, idleService) {
              idleService ??= IdleTimeoutService();
              idleService.configure(authProvider: auth, settingsProvider: settings);
              return idleService;
            },
          ),
          ChangeNotifierProxyProvider<AuthProvider, PasswordProvider>(
            create: (_) => PasswordProvider(),
            update: (_, auth, passwordProvider) {
              passwordProvider ??= PasswordProvider();
              passwordProvider.updateAuthProvider(auth);
              return passwordProvider;
            },
          ),
          ChangeNotifierProvider(create: (_) => DocProvider()),
        ],
        child: const MyApp(),
      ),
    );
  }
}
