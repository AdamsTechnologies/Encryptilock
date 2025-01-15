import 'package:flutter/material.dart';
import 'package:encryptilock/frontend/screens/passwords_screen.dart';
import 'package:encryptilock/frontend/screens/settings_screen.dart';
import 'package:encryptilock/frontend/screens/info_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Encryptilock'),
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
                        selectedIndex: tabController?.index ?? 0,
                        onDestinationSelected: (index) {
                          tabController?.animateTo(index);
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
          );
        },
      ),
    );
  }
}
