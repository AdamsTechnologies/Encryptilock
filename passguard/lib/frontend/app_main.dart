import 'package:flutter/material.dart';
import 'package:passguard/frontend/screens/passwords_screen.dart';
import 'package:passguard/frontend/screens/settings_screen.dart';
import 'package:passguard/frontend/screens/info_screen.dart';
/*
lib/
├── main.dart                  # Entry point; initializes settings and providers
├── providers/                 # Providers for managing app state
│   ├── auth_provider.dart     # Handles authentication and app lock/logout
│   ├── settings_provider.dart # Manages app-wide settings (theme, idle timeout)
├── screens/                   # UI screens for each part of the app
│   ├── login_screen.dart      # Login screen
│   ├── passwords_screen.dart  # Passwords management screen
│   ├── settings_screen.dart   # App settings screen
│   ├── info_screen.dart       # Info tab screen
├── widgets/                   # Reusable UI components
│   ├── password_list_item.dart # Widget for individual password items
│   ├── password_generator_dialog.dart # Complex password generator dialog
├── services/                  # Utilities for DB, encryption, etc.
│   ├── sqlite_service.dart    # SQLite service for settings and password DB
│   ├── encryption_service.dart # Placeholder for encryption logic
*/ 
class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PassGuard'),
          bottom: isDesktop
              ? null
              : const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.info), text: 'Info'),
                    Tab(icon: Icon(Icons.lock), text: 'Passwords'),
                    Tab(icon: Icon(Icons.settings), text: 'Settings'),
                  ],
                ),
        ),
        body: isDesktop
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: DefaultTabController.of(context)?.index ?? 0,
                    onDestinationSelected: (index) {
                      DefaultTabController.of(context)?.animateTo(index);
                    },
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.info),
                        label: Text('Info'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.lock),
                        label: Text('Passwords'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings),
                        label: Text('Settings'),
                      ),
                    ],
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        InfoScreen(),
                        PasswordsScreen(),
                        SettingsScreen(),
                      ],
                    ),
                  ),
                ],
              )
            : const TabBarView(
                children: [
                  InfoScreen(),
                  PasswordsScreen(),
                  SettingsScreen(),
                ],
              ),
      ),
    );
  }
}

