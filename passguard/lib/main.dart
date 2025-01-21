import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:passguard/frontend/app_main.dart';
import 'frontend/theme/theme_config.dart';
import 'frontend/screens/login_screen.dart';
import 'frontend/providers/auth_provider.dart';
import 'frontend/providers/theme_provider.dart';
import 'backend/databaseManager/dart_sqlite.dart';
import 'frontend/providers/settings_provider.dart';
import 'backend/controllers/config_settings_controller.dart';
import 'frontend/providers/password_provider.dart';
import 'frontend/providers/idle_timeout_provider.dart';
import 'package:passguard/frontend/services/idle_timeout_wrapper.dart';
import 'package:passguard/frontend/providers/snackbar_provider.dart';
import 'package:passguard/frontend/widgets/permanent_snackbar.dart';

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
      ) ?? ThemeConfig.defaultBorderRadius;

  // Create a GlobalKey for navigation
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            configManager,
            initialTheme: initialTheme,
            initialIdleTimeout: initialIdleTimeout,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(configManager: configManager),
        ),
        ProxyProvider<AuthProvider, PasswordProvider>(
          update: (_, authProvider, __) => PasswordProvider(authProvider: authProvider),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(
            ThemeConfig.getTheme(initialTheme, borderRadius: borderRadius),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => IdleTimeoutProvider(navigatorKey: navigatorKey),
        ),
        ChangeNotifierProvider(
          create: (_) => SnackBarProvider(), // Add SnackBarProvider to the providers list
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'PassGuard',
            theme: themeProvider.theme,
            darkTheme: ThemeConfig.getTheme('dark', borderRadius: borderRadius),
            themeMode: ThemeMode.light, // Update dynamically as needed
            home: Stack(
              children: [
                AppWithIdleTimeout(
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return authProvider.isLoggedIn ? const MainApp() : LoginScreen();
                    },
                  ),
                ),
                // Add the PermanentSnackBar to the widget tree
                Consumer<SnackBarProvider>(
                  builder: (context, snackBarProvider, _) {
                    return PermanentSnackBar(snackBarProvider: snackBarProvider);
                  },
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:passguard/frontend/app_main.dart';
// import 'frontend/theme/theme_config.dart';
// import 'frontend/screens/login_screen.dart';
// import 'frontend/providers/auth_provider.dart';
// import 'frontend/providers/theme_provider.dart';
// import 'backend/databaseManager/dart_sqlite.dart';
// import 'frontend/providers/settings_provider.dart';
// import 'backend/controllers/config_settings_controller.dart';
// import 'frontend/providers/password_provider.dart';
// import 'frontend/providers/idle_timeout_provider.dart'; // Import IdleTimeoutProvider
// import 'package:passguard/frontend/services/idle_timeout_wrapper.dart';
// import 'package:passguard/frontend/providers/snackbar_provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize SQLite and settings manager
//   final settingsDb = DartSqlite(dbFile: 'configsettings.db');
//   settingsDb.open();
//   final configManager = ConfigSettingsController(settingsDb);

//   // Load initial settings
//   final initialTheme = await configManager.getSetting('theme') ?? 'light';
//   final initialIdleTimeout = int.tryParse(await configManager.getSetting('idle_timeout') ?? '5') ?? 5;

//   // Parse borderRadius from configuration
//   final borderRadius = double.tryParse(
//         await configManager.getSetting('border_radius') ?? '${ThemeConfig.defaultBorderRadius}',
//       ) ?? ThemeConfig.defaultBorderRadius;

//   // Create a GlobalKey for navigation
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//           create: (_) => SettingsProvider(
//             configManager,
//             initialTheme: initialTheme,
//             initialIdleTimeout: initialIdleTimeout,
//           ),
//         ),
//         ChangeNotifierProvider(
//           create: (_) => AuthProvider(configManager: configManager),
//         ),
//         ProxyProvider<AuthProvider, PasswordProvider>(
//           update: (_, authProvider, __) => PasswordProvider(authProvider: authProvider),
//         ),
//         ChangeNotifierProvider(
//           create: (_) => ThemeProvider(
//             ThemeConfig.getTheme(initialTheme, borderRadius: borderRadius),
//           ),
//         ),
//         ChangeNotifierProvider(
//           create: (_) => IdleTimeoutProvider(navigatorKey: navigatorKey),
//         ),
//       ],
//       child: Consumer<ThemeProvider>(
//         builder: (context, themeProvider, _) {
//           return MaterialApp(
//             navigatorKey: navigatorKey,
//             title: 'PassGuard',
//             theme: themeProvider.theme,
//             darkTheme: ThemeConfig.getTheme('dark', borderRadius: borderRadius),
//             themeMode: ThemeMode.light, // Update dynamically as needed
//             home: AppWithIdleTimeout(  // Wrap the home widget with AppWithIdleTimeout
//               child: Consumer<AuthProvider>(
//                 builder: (context, authProvider, _) {
//                   return authProvider.isLoggedIn ? const MainApp() : LoginScreen();
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     ),
//   );
// }
