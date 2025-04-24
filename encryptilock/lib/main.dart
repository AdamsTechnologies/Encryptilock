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

import 'dart:io';
import 'package:desktop_window/desktop_window.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsDbPath = await getLocalPath('s1.db');
  final settingsDb = DartSqlite(dbFile: settingsDbPath);
  settingsDb.open();
  final configManager = await ConfigSettingsController.init(settingsDb);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await DesktopWindow.setWindowSize(const Size(850, 650));
    await DesktopWindow.setMinWindowSize(const Size(400, 300));
    await DesktopWindow.setMaxWindowSize(const Size(double.infinity, double.infinity));

    await windowManager.ensureInitialized();
    windowManager.setPreventClose(true);
    windowManager.addListener(_WindowCloseHandler());
  }

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
      ],
      child: const MyApp(),
    ),
  );
}

class _WindowCloseHandler extends WindowListener {
  @override
  Future onWindowClose() async {
    final isPreventClose = await windowManager.isPreventClose();
    if (!isPreventClose) return;

    final context = navigatorKey.currentContext;
    if (context != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final settingProvider = Provider.of<SettingsProvider>(context, listen: false);
      if (settingProvider.clearFiltersOnLogout == true) {
        await settingProvider.clearCategoryFilters();
      }
      if (authProvider.isLoggedIn) {
        await authProvider.logout(isAppShutdown: true);
      }
    }

    await windowManager.setPreventClose(false);
    await windowManager.close();
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(builder: (ctx, auth, themeProvider, _) {
      return MaterialApp(
        title: 'Encryptilock',
        navigatorKey: navigatorKey,
        theme: themeProvider.theme,
        home: auth.isShuttingDown
            ? Container()
            : auth.isLoggedIn
                ? const IdleWrapper(child: MainApp())
                : LoginScreen(),
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
