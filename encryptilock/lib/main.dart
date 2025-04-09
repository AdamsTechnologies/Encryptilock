import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:encryptilock/frontend/app_main.dart';
import 'package:encryptilock/backend/databaseManager/dart_sqlite.dart';
import 'package:encryptilock/backend/controllers/config_settings_controller.dart';

import 'package:encryptilock/frontend/services/idle_timeout_service.dart';

import 'package:encryptilock/frontend/providers/auth_provider.dart';
import 'package:encryptilock/frontend/providers/settings_provider.dart';
import 'package:encryptilock/frontend/providers/theme_provider.dart';
import 'package:encryptilock/frontend/providers/snackbar_provider.dart';
import 'package:encryptilock/frontend/providers/password_provider.dart';
import 'package:encryptilock/backend/helpers/path_utils.dart';

import 'package:encryptilock/frontend/screens/login_screen.dart';
import 'package:encryptilock/frontend/theme/theme_config.dart';
import 'package:encryptilock/frontend/providers/document_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsDbPath = await getLocalPath('s1.db');
  final settingsDb = DartSqlite(dbFile: settingsDbPath);
  settingsDb.open();
  final configManager = await ConfigSettingsController.init(settingsDb);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SnackBarProvider()),
        ChangeNotifierProxyProvider<SnackBarProvider, AuthProvider>(
          create: (_) => AuthProvider(configManager: configManager),
          update: (_, snackBarProvider, authProvider) => authProvider!..updateSnackBarProvider(snackBarProvider),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider(configManager)..loadSettings()),
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
        // ChangeNotifierProxyProvider<AuthProvider, DocProvider>(
        //   create: (_) => DocProvider(),
        //   update: (_, auth, docProvider) {
        //     docProvider ??= DocProvider();
        //     return docProvider;
        //   },
        // ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize SQLite and settings manager
//   final settingsDbPath = await getLocalPath('s1.db');
//   final settingsDb = DartSqlite(dbFile: settingsDbPath);
//   settingsDb.open();
//   // final configManager = ConfigSettingsController(settingsDb);
//   final configManager = await ConfigSettingsController.init(settingsDb);

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => SnackBarProvider()),
//         ChangeNotifierProxyProvider<SnackBarProvider, AuthProvider>(
//           create: (_) => AuthProvider(configManager: configManager),
//           update: (_, snackBarProvider, authProvider) => authProvider!..updateSnackBarProvider(snackBarProvider),
//         ),
//         ChangeNotifierProvider(create: (_) => SettingsProvider(configManager)..loadSettings()),
//         ChangeNotifierProxyProvider<SettingsProvider, ThemeProvider>(
//           create: (context) {
//             final settings = Provider.of<SettingsProvider>(context, listen: false);
//             final themeData = ThemeConfig.getTheme(settings.settingsTheme);
//             return ThemeProvider(themeData);
//           },
//           update: (context, settings, themeProvider) {
//             themeProvider?.setTheme(ThemeConfig.getTheme(settings.settingsTheme));
//             return themeProvider!;
//           },
//         ),
//         ChangeNotifierProxyProvider2<AuthProvider, SettingsProvider, IdleTimeoutService>(
//           create: (_) => IdleTimeoutService(),
//           update: (_, auth, settings, idleService) {
//             idleService ??= IdleTimeoutService();
//             idleService.configure(authProvider: auth, settingsProvider: settings);
//             return idleService;
//           },
//         ),
//         ChangeNotifierProxyProvider<AuthProvider, PasswordProvider>(
//           create: (_) => PasswordProvider(),
//           update: (_, auth, passwordProvider) {
//             passwordProvider ??= PasswordProvider();
//             passwordProvider.updateAuthProvider(auth);
//             return passwordProvider;
//           },
//         ),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }