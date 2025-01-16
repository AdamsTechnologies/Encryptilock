import 'package:flutter/material.dart';
import 'package:passguard/frontend/screens/info_screen.dart';
import 'package:passguard/frontend/screens/passwords_screen.dart';
import 'package:passguard/frontend/screens/settings_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  int? hoveredIndex;
  bool isPointerInsideNavRegion = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('PassGuard'),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.info), text: 'Info'),
                  Tab(icon: Icon(Icons.lock), text: 'Passwords'),
                  Tab(icon: Icon(Icons.settings), text: 'Settings'),
                ],
              ),
            ),
      body: isDesktop
          ? Stack(
              children: [
                Row(
                  children: [
                    _buildNavigationRail(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          InfoScreen(),
                          PasswordsScreen(),
                          SettingsScreen(),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildExpandableDrawer(theme),
              ],
            )
          : TabBarView(
              controller: _tabController,
              children: const [
                InfoScreen(),
                PasswordsScreen(),
                SettingsScreen(),
              ],
            ),
    );
  }

  Widget _buildNavigationRail() {
    final selectedIndex = _tabController.index;

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          hoveredIndex = null;
          _tabController.animateTo(index);
        });
      },
      destinations: [
        _buildRailDestination(Icons.info, 'Info', 0),
        _buildRailDestination(Icons.lock, 'Passwords', 1),
        _buildRailDestination(Icons.settings, 'Settings', 2),
      ],
    );
  }

  NavigationRailDestination _buildRailDestination(IconData icon, String label, int index) {
    return NavigationRailDestination(
      icon: MouseRegion(
        onEnter: (_) => setState(() => hoveredIndex = index),
        onExit: (_) {
          if (!isPointerInsideNavRegion) {
            setState(() => hoveredIndex = null);
          }
        },
        child: Icon(icon, color: hoveredIndex == index ? Theme.of(context).colorScheme.primary : null),
      ),
      label: Text(label),
    );
  }

  Widget _buildExpandableDrawer(ThemeData theme) {
    final selectedIndex = _tabController.index;
    final showDrawer = hoveredIndex != null && hoveredIndex != selectedIndex && isPointerInsideNavRegion;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: showDrawer ? 72 : -250,
      top: 0,
      bottom: 0,
      width: 250,
      child: Material(
        elevation: 4,
        color: theme.colorScheme.surface,
        child: showDrawer
            ? _buildDrawerContent(hoveredIndex!, theme)
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildDrawerContent(int index, ThemeData theme) {
    switch (index) {
      case 1:
        return _buildPasswordsDrawerContent(theme);
      case 2:
        return _buildSettingsDrawerContent(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPasswordsDrawerContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search Passwords',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => ListTile(
              leading: SizedBox(
                width: 24,
                child: Icon(Icons.vpn_key, color: theme.colorScheme.primary),
              ),
              title: Text('Password $index'),
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsDrawerContent(ThemeData theme) {
    return Column(
      children: [
        ListTile(
          title: const Text('Toggle Dark Mode'),
          trailing: Switch(
            value: false,
            onChanged: (val) {},
          ),
        ),
        ListTile(
          title: const Text('Idle Timeout'),
          subtitle: const Text('5 minutes'),
          onTap: () {},
        ),
      ],
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainApp()),
            );
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:passguard/frontend/screens/info_screen.dart';
// import 'package:passguard/frontend/screens/passwords_screen.dart';
// import 'package:passguard/frontend/screens/settings_screen.dart';

// class MainApp extends StatefulWidget {
//   const MainApp({Key? key}) : super(key: key);

//   @override
//   State<MainApp> createState() => _MainAppState();
// }

// class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
//   int? hoveredIndex;
//   bool isPointerInsideNavRegion = false;
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDesktop = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       appBar: isDesktop
//           ? null
//           : AppBar(
//               title: const Text('PassGuard'),
//               bottom: TabBar(
//                 controller: _tabController,
//                 tabs: const [
//                   Tab(icon: Icon(Icons.info), text: 'Info'),
//                   Tab(icon: Icon(Icons.lock), text: 'Passwords'),
//                   Tab(icon: Icon(Icons.settings), text: 'Settings'),
//                 ],
//               ),
//             ),
//       body: isDesktop
//           ? Row(
//               children: [
//                 MouseRegion(
//                   onEnter: (_) {
//                     setState(() => isPointerInsideNavRegion = true);
//                   },
//                   onExit: (_) {
//                     setState(() {
//                       isPointerInsideNavRegion = false;
//                       hoveredIndex = null;
//                     });
//                   },
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       _buildNavigationRail(),
//                       _buildExpandableDrawer(theme),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     controller: _tabController,
//                     children: const [
//                       InfoScreen(),
//                       PasswordsScreen(),
//                       SettingsScreen(),
//                     ],
//                   ),
//                 ),
//               ],
//             )
//           : TabBarView(
//               controller: _tabController,
//               children: const [
//                 InfoScreen(),
//                 PasswordsScreen(),
//                 SettingsScreen(),
//               ],
//             ),
//     );
//   }

//   Widget _buildNavigationRail() {
//     final selectedIndex = _tabController.index;

//     return NavigationRail(
//       selectedIndex: selectedIndex,
//       onDestinationSelected: (index) {
//         setState(() {
//           hoveredIndex = null;
//           _tabController.animateTo(index);
//         });
//       },
//       destinations: const [
//         NavigationRailDestination(
//           icon: Icon(Icons.info),
//           label: Text('Info'),
//         ),
//         NavigationRailDestination(
//           icon: Icon(Icons.lock),
//           label: Text('Passwords'),
//         ),
//         NavigationRailDestination(
//           icon: Icon(Icons.settings),
//           label: Text('Settings'),
//         ),
//       ],
//     );
//   }

//   Widget _buildExpandableDrawer(ThemeData theme) {
//     final selectedIndex = _tabController.index;
//     final showDrawer = hoveredIndex != null && hoveredIndex != selectedIndex && isPointerInsideNavRegion;

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       width: showDrawer ? 250 : 0,
//       color: theme.colorScheme.surface,
//       child: showDrawer
//           ? _buildDrawerContent(hoveredIndex!, theme)
//           : const SizedBox.shrink(),
//     );
//   }

//   Widget _buildDrawerContent(int index, ThemeData theme) {
//     switch (index) {
//       case 1:
//         return _buildPasswordsDrawerContent(theme);
//       case 2:
//         return _buildSettingsDrawerContent(theme);
//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   Widget _buildPasswordsDrawerContent(ThemeData theme) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: TextField(
//             decoration: InputDecoration(
//               labelText: 'Search Passwords',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(4.0),
//               ),
//               prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
//             ),
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             itemCount: 5,
//             itemBuilder: (context, index) => ListTile(
//               leading: Icon(Icons.vpn_key, color: theme.colorScheme.primary),
//               title: Text('Password $index'),
//               onTap: () {},
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSettingsDrawerContent(ThemeData theme) {
//     return Column(
//       children: [
//         ListTile(
//           title: const Text('Toggle Dark Mode'),
//           trailing: Switch(
//             value: false,
//             onChanged: (val) {},
//           ),
//         ),
//         ListTile(
//           title: const Text('Idle Timeout'),
//           subtitle: const Text('5 minutes'),
//           onTap: () {},
//         ),
//       ],
//     );
//   }
// }

// ------------------------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------- STABLE BELOW , VISUALLY BETTER ABOVE.
// ------------------------------------------------------------------------------------------------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:passguard/frontend/screens/passwords_screen.dart';
// import 'package:passguard/frontend/screens/settings_screen.dart';
// import 'package:passguard/frontend/screens/info_screen.dart';
// import 'package:passguard/frontend/widgets/password_list_view.dart'; // Import PasswordListView

// class MainApp extends StatefulWidget {
//   const MainApp({Key? key}) : super(key: key);

//   @override
//   State<MainApp> createState() => _MainAppState();
// }

// class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
//   int? hoveredIndex;
//   bool isPointerInsideNavRegion = false;
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: navItems.length, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   final List<_NavItem> navItems = const [
//     _NavItem(label: 'Info', icon: Icons.info),
//     _NavItem(label: 'Passwords', icon: Icons.lock),
//     _NavItem(label: 'Settings', icon: Icons.settings),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDesktop = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PassGuard'),
//         bottom: isDesktop
//             ? null
//             : TabBar(
//                 controller: _tabController,
//                 tabs: navItems.map((item) {
//                   return Tab(icon: Icon(item.icon), text: item.label);
//                 }).toList(),
//               ),
//       ),
//       body: isDesktop
//           ? Row(
//               children: [
//                 MouseRegion(
//                   onEnter: (_) {
//                     setState(() => isPointerInsideNavRegion = true);
//                   },
//                   onExit: (_) {
//                     setState(() {
//                       isPointerInsideNavRegion = false;
//                       hoveredIndex = null;
//                     });
//                   },
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       _buildNavRail(),
//                       _buildVerticalDivider(theme),
//                       _buildExpandableDrawer(theme),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     controller: _tabController,
//                     children: const [
//                       InfoScreen(),
//                       PasswordsScreen(),
//                       SettingsScreen(),
//                     ],
//                   ),
//                 ),
//               ],
//             )
//           : TabBarView(
//               controller: _tabController,
//               children: const [
//                 InfoScreen(),
//                 PasswordsScreen(),
//                 SettingsScreen(),
//               ],
//             ),
//     );
//   }

//   Widget _buildNavRail() {
//     final selectedIndex = _tabController.index;

//     return NavigationRail(
//       selectedIndex: selectedIndex,
//       onDestinationSelected: (index) {
//         setState(() {
//           hoveredIndex = null;
//           _tabController.animateTo(index);
//         });
//       },
//       destinations: navItems.asMap().entries.map((entry) {
//         final i = entry.key;
//         final item = entry.value;
//         return NavigationRailDestination(
//           icon: MouseRegion(
//             onEnter: (_) => setState(() => hoveredIndex = i),
//             onExit: (_) {},
//             child: Icon(item.icon),
//           ),
//           label: Text(item.label),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildVerticalDivider(ThemeData theme) {
//     final selectedIndex = _tabController.index;
//     final showDrawer = hoveredIndex != null && hoveredIndex != selectedIndex && isPointerInsideNavRegion;
//     return VerticalDivider(
//       width: showDrawer ? 1 : 0,
//       thickness: 1,
//       color: theme.dividerColor,
//     );
//   }

//   Widget _buildExpandableDrawer(ThemeData theme) {
//     final selectedIndex = _tabController.index;
//     final showDrawer = hoveredIndex != null && hoveredIndex != selectedIndex && isPointerInsideNavRegion;

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeInOut,
//       width: showDrawer ? 250 : 0,
//       color: theme.colorScheme.surface,
//       child: showDrawer ? _buildDrawerContent(hoveredIndex!, theme) : const SizedBox.shrink(),
//     );
//   }

//   Widget _buildDrawerContent(int index, ThemeData theme) {
//     switch (index) {
//       case 1:
//         return _buildPasswordsDrawerContent(theme);
//       case 2:
//         return _buildSettingsDrawerContent(theme);
//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   Widget _buildPasswordsDrawerContent(ThemeData theme) {
//     final dummyEntries = List.generate(
//       10,
//       (i) => PasswordEntry(
//         id: i.toString(),
//         service: 'Service $i',
//         serviceType: 'Type $i',
//         username: 'User $i',
//         creationDate: '2023-12-${i + 1}',
//       ),
//     );

//     return PasswordListView(
//       passwordEntries: dummyEntries,
//       onEntryTap: (entry) {
//         debugPrint('Tapped on: ${entry.service}');
//       },
//     );
//   }

//   Widget _buildSettingsDrawerContent(ThemeData theme) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           ListTile(
//             title: const Text('Toggle Dark Mode'),
//             trailing: Switch(
//               value: false,
//               onChanged: (val) {},
//             ),
//           ),
//           ListTile(
//             title: const Text('Idle Timeout'),
//             subtitle: const Text('5 minutes'),
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _NavItem {
//   final String label;
//   final IconData icon;
//   const _NavItem({required this.label, required this.icon});
// }
