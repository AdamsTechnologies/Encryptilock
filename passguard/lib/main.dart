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

void main() async  {
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
  // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  runApp(
    MultiProvider(
      providers: [
        // Provide AuthProvider:
        ChangeNotifierProvider(create: (_) => AuthProvider(configManager: configManager)),

        // Provide SettingsProvider (with an idleTimeout default):
        ChangeNotifierProvider(create: (_) => SettingsProvider(configManager, initialTheme: initialTheme, initialIdleTimeout: initialIdleTimeout)),

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
    return Consumer<AuthProvider>(
      builder: (ctx, auth, _) {
        return MaterialApp(
          title: 'Encryptilock',
          theme: ThemeData.light(),
          home: auth.isLoggedIn ? const IdleWrapper(child: MainApp()) : LoginScreen(),
          // initialRoute: auth.isLoggedIn ? '/home' : '/login',
          // routes: {
          //   '/login': (_) => LoginScreen(),
          //   '/home': (_) => const IdleWrapper(child: MainApp()),
          // },
        );
      }
    );
    // return MaterialApp(
    //   title: 'PassGuard Idle Demo',
    //   theme: ThemeData.light(),
    //   // Provide named routes for login & home:
    //   initialRoute: '/login',
      // routes: {
      //   '/login': (_) => LoginScreen(),
      //   '/home': (_) => const IdleWrapper(child: MainApp()),
      // },
    // );
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


// class HomeWrapper extends StatelessWidget {
//   final Widget child;

//   const HomeWrapper({Key? key, required this.child}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final idleTimeoutService = Provider.of<IdleTimeoutService>(context, listen: false);
//     return Listener(
//       behavior: HitTestBehavior.translucent,
//       onPointerDown: (_) => idleTimeoutService.resetTimer(),
//       onPointerMove: (_) => idleTimeoutService.resetTimer(),
//       child: child,
//     );
//   }
// }

// ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------

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
// // import 'frontend/providers/idle_timeout_provider.dart';
// import 'package:passguard/frontend/services/idle_timeout_wrapper.dart';
// import 'package:passguard/frontend/providers/snackbar_provider.dart';
// import 'package:passguard/frontend/widgets/permanent_snackbar.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

  // // Initialize SQLite and settings manager
  // final settingsDb = DartSqlite(dbFile: 'configsettings.db');
  // settingsDb.open();
  // final configManager = ConfigSettingsController(settingsDb);

  // // Load initial settings
  // final initialTheme = await configManager.getSetting('theme') ?? 'light';
  // final initialIdleTimeout = int.tryParse(await configManager.getSetting('idle_timeout') ?? '5') ?? 5;

  // // Parse borderRadius from configuration
  // final borderRadius = double.tryParse(
  //       await configManager.getSetting('border_radius') ?? '${ThemeConfig.defaultBorderRadius}',
  //     ) ?? ThemeConfig.defaultBorderRadius;

  // // Create a GlobalKey for navigation
  // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
//         ChangeNotifierProvider(
//           create: (_) => SnackBarProvider(), // Add SnackBarProvider to the providers list
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
//             home: Stack(
//               children: [
//                 AppWithIdleTimeout(
//                   child: Consumer<AuthProvider>(
//                     builder: (context, authProvider, _) {
//                       return authProvider.isLoggedIn ? const MainApp() : LoginScreen();
//                     },
//                   ),
//                 ),
//                 // Add the PermanentSnackBar to the widget tree
//                 Consumer<SnackBarProvider>(
//                   builder: (context, snackBarProvider, _) {
//                     return PermanentSnackBar(snackBarProvider: snackBarProvider);
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     ),
//   );
// }


/// -------------------------------------------------------------------------------- OLDER
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
