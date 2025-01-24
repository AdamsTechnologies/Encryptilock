import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passguard/backend/databaseManager/dart_sqlite.dart';
import 'package:passguard/backend/controllers/config_settings_controller.dart';
import 'package:passguard/frontend/providers/auth_provider.dart';
import 'package:passguard/frontend/providers/settings_provider.dart';
import 'package:passguard/frontend/providers/theme_provider.dart';
import 'package:passguard/frontend/providers/snackbar_provider.dart';
import 'package:passguard/frontend/services/idle_timeout_service.dart';
import 'package:passguard/frontend/theme/theme_config.dart';

import 'package:passguard/frontend/screens/login_screen.dart';
import 'package:passguard/frontend/app_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize SQLite and settings manager
  final settingsDb = DartSqlite(dbFile: 'configsettings.db');
  settingsDb.open();
  final configManager = ConfigSettingsController(settingsDb);

  // Load initial settings
  final initialTheme = await configManager.getSetting('theme') ?? 'light';
  final initialIdleTimeout = int.tryParse(await configManager.getSetting('idle_timeout') ?? '5') ?? 5;

  // Parse borderRadius from configuration
  final borderRadius = double.tryParse(
        await configManager.getSetting('border_radius') ?? '${ThemeConfig.defaultBorderRadius}',
      ) ??
      ThemeConfig.defaultBorderRadius;

  runApp(
    MultiProvider(
      providers: [
        // Snackbar
        ChangeNotifierProvider(create: (_) => SnackBarProvider()),
        // Provide AuthProvider:
        ChangeNotifierProxyProvider<SnackBarProvider, AuthProvider>(
          create: (_) => AuthProvider(configManager: configManager), // create the AuthProvider
          update: (_, snackBarProvider, authProvider) => authProvider!..updateSnackBarProvider(snackBarProvider),
        ),
        // Provide SettingsProvider (with an idleTimeout default):
        ChangeNotifierProvider(create: (_) => SettingsProvider(configManager, initialTheme: initialTheme, initialIdleTimeout: initialIdleTimeout)),
        // Provide ThemeProvider (depends on SettingsProvider)
        ChangeNotifierProxyProvider<SettingsProvider, ThemeProvider>(
          create: (context) {
            final settings = Provider.of<SettingsProvider>(context, listen: false);
            // Build an initial ThemeData based on the settings
            final themeData = ThemeConfig.getTheme(
              settings.settingsTheme,
              borderRadius: borderRadius,
            );
            return ThemeProvider(themeData);
          },
          update: (context, settings, themeProvider) {
            final newThemeData = ThemeConfig.getTheme(
              settings.settingsTheme,
              borderRadius: borderRadius,
            );
            themeProvider?.setTheme(newThemeData);
            return themeProvider!;
          },
        ),
        // Provide IdleTimeoutService, re-wiring references from Auth & Settings:
        ChangeNotifierProxyProvider2<AuthProvider, SettingsProvider, IdleTimeoutService>(
          create: (_) => IdleTimeoutService(),
          update: (_, auth, settings, idleService) {
            idleService ??= IdleTimeoutService();
            // re-wire references:
            idleService.configure(
              authProvider: auth,
              settingsProvider: settings,
            );
            return idleService;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// The root of your app, hosting [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  /// Return the top-level MaterialApp with named routes.
  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(builder: (ctx, auth, themeProvider, _) {
      return MaterialApp(
        title: 'Encryptilock',
        theme: themeProvider.theme,
        home: auth.isLoggedIn ? const IdleWrapper(child: MainApp()) : LoginScreen(),
      );
    });
  }
}

/// Wrap this around "logged-in" screens to intercept user events.
class IdleWrapper extends StatelessWidget {
  final Widget child;
  const IdleWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final idleService = Provider.of<IdleTimeoutService>(context, listen: false);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => idleService.resetTimer(),
      onPointerMove: (_) => idleService.resetTimer(),
      child: child,
    );
  }
}
