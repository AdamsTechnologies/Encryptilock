import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:passguard/frontend/screens/info_screen.dart';
import 'package:passguard/frontend/screens/passwords_screen.dart';
import 'package:passguard/frontend/screens/settings_screen.dart';
import 'package:passguard/frontend/theme/theme_config.dart';
import 'package:passguard/frontend/widgets/permanent_snackbar.dart';

import 'package:provider/provider.dart';
import 'package:passguard/frontend/widgets/info_drawer_content.dart';
import 'package:passguard/frontend/providers/auth_provider.dart';
import 'package:passguard/frontend/providers/snackbar_provider.dart';
import 'package:passguard/frontend/widgets/password_list_view.dart';

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Pinned index -> which tab is "locked" open.
  /// We'll only ever pin tab #1 (Passwords).
  int? pinnedIndex;

  /// Hovered index -> which tab is hovered, if any.
  /// We'll use 0 or 1 for Info or Passwords. We'll ignore 2 (Settings).
  int? hoveredIndex;

  bool isDrawerHovered = false;
  Timer? _closeTimer;

  static const double _navRailWidth = 72;
  static const double _drawerWidth = 250;
  static const Duration _closeDelay = Duration(milliseconds: 200);

  bool get isDesktop => MediaQuery.of(context).size.width > 600;

  @override
  void initState() {
    super.initState();
    // 3 tabs -> Info(0), Passwords(1), Settings(2)
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  /// Which tab's drawer should we currently display, if any?
  /// Priority: hoveredIndex over pinnedIndex.
  int? get displayedDrawerIndex => hoveredIndex ?? pinnedIndex;

  /// Do we show a drawer at all?
  /// Only if displayedDrawerIndex is 0 (Info) or 1 (Passwords).
  bool get shouldShowDrawer {
    final di = displayedDrawerIndex;
    return di == 0 || di == 1;
  }

  /// Do we shift the main content?
  /// Only if the pinned tab is #1 (Passwords) is currently displayed.
  bool get shouldShiftContent => pinnedIndex == 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Encryptilock'),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.info), text: 'Info'),
                  Tab(icon: Icon(Icons.lock), text: 'Passwords'),
                  Tab(icon: Icon(Icons.settings), text: 'Settings'),
                ],
              ),
            ),
      body: Stack(
        children: [
          // --- Desktop layout ---
          if (isDesktop) ...[
            // Main content: shift only if pinnedIndex == 1 (Passwords)
            Positioned(
              left: _navRailWidth, // + (shouldShiftContent ? _drawerWidth : 0)
              right: 0,
              top: 0,
              bottom: 0,
              // Using the TabBarView normally, but let's disable swipe animation:
              child: TabBarView(
                controller: _tabController,
                // physics: const NeverScrollableScrollPhysics(), // no gesture-swipe
                children: [
                  Padding(padding: EdgeInsets.only(), child: const InfoScreen()),
                  Padding(padding: EdgeInsets.only(left: shouldShiftContent ? _drawerWidth : 0), child: const PasswordsScreen()),
                  Padding(padding: EdgeInsets.only(), child: const SettingsScreen()),
                ],
              ),
            ),
            PermanentSnackBar(
              // place snackbar behind nav-drawer.
              height: 30.0,
              backgroundColor: theme.colorScheme.surface,
              // leftPaddingWhenDrawerOpen: shouldShiftContent ? _navRailWidth + 6 + _drawerWidth : _navRailWidth + 8,
            ),
            _buildExpandableDrawer(),
            // The nav rail pinned at left
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildNavigationRail(),
            ),
            // Permanent bottom bar (optionally shift it if pinned)
          ] else ...[
            // --- Mobile layout ---
            TabBarView(
              controller: _tabController,
              children: const [
                InfoScreen(),
                PasswordsScreen(),
                SettingsScreen(),
              ],
            ),
            PermanentSnackBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationRail() {
    final theme = Theme.of(context);

    return NavigationRail(
      backgroundColor: theme.colorScheme.surface,
      selectedIndex: _tabController.index,
      onDestinationSelected: (index) {
        setState(() {
          if (index == 3) {
            _appLogout(context);
          } else {
            _tabController.animateTo(index);
            if (index == 1) {
              pinnedIndex = 1;
            } else {
              // For Info(0) or Settings(2), no pinned drawer
              pinnedIndex = null;
            }
            hoveredIndex = null;
          }
        });
      },
      destinations: [
        _buildRailDestination(Icons.info, 'Info', 0),
        _buildRailDestination(Icons.lock, 'Passwords', 1),
        _buildRailDestination(Icons.settings, 'Settings', 2),
        _buildLogoutRailDestination(),
      ],
      indicatorShape: const BeveledRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4), bottom: Radius.circular(4)),
      ),
    );
  }

  NavigationRailDestination _buildRailDestination(IconData icon, String label, int index) {
    return NavigationRailDestination(
      icon: SizedBox(
        width: _navRailWidth,
        child: MouseRegion(
          onEnter: (_) {
            // Only hover Info(0) or Passwords(1).
            // We don't do a drawer for Settings(2).
            if (index == 0 || index == 1) {
              _closeTimer?.cancel();
              setState(() => hoveredIndex = index);
            }
          },
          onExit: (_) {
            // Start close timer. If user doesn't enter the drawer, we'll revert hoveredIndex.
            _startCloseTimer();
          },
          child: Center(
            child: Icon(
              icon,
              // Highlight if pinned OR hovered
              color: (pinnedIndex == index || hoveredIndex == index) ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ),
      ),
      label: Text(label),
    );
  }

  NavigationRailDestination _buildLogoutRailDestination() {
    return const NavigationRailDestination(
      icon: Icon(Icons.power_settings_new),
      label: Text('Logout'),
    );
  }

  void _appLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    SystemNavigator.pop();
  }

  /// After a short delay, if the mouse is not over the drawer,
  /// revert to pinnedIndex only (clear hoveredIndex).
  void _startCloseTimer() {
    _closeTimer?.cancel();
    _closeTimer = Timer(_closeDelay, () {
      if (!mounted) return;
      if (!isDrawerHovered) {
        setState(() {
          hoveredIndex = null;
        });
      }
    });
  }

  Widget _buildExpandableDrawer() {
    final theme = Theme.of(context);
    return AnimatedPositioned(
      duration: shouldShowDrawer ? const Duration(milliseconds: 200) : const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      // If we should show the drawer (info or passwords), place it flush at navRailWidth
      // Otherwise hide it to the left
      left: shouldShowDrawer ? _navRailWidth + 5 : _navRailWidth - _drawerWidth,
      top: 0,
      bottom: 0,
      width: _drawerWidth,
      child: MouseRegion(
        onEnter: (_) {
          _closeTimer?.cancel();
          setState(() => isDrawerHovered = true);
        },
        onExit: (_) {
          setState(() => isDrawerHovered = false);
          _startCloseTimer();
        },
        child: Material(
          elevation: 4,
          color: theme.colorScheme.surface,
          child: shouldShowDrawer && displayedDrawerIndex != null
              ? Container(
                  padding: const EdgeInsets.fromLTRB(3, 5, 3, 5),
                  foregroundDecoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        width: 5,
                      ),
                    ),
                  ),
                  child: _buildDrawerContent(displayedDrawerIndex!, theme),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  /// We only build drawer content for Info(0) and Passwords(1).
  Widget _buildDrawerContent(int index, ThemeData theme) {
    switch (index) {
      case 0:
        // Info drawer content
        return const InfoDrawerContent(websiteUrl: 'www.passguard9000.com');
      case 1:
        // Password drawer content
        return _buildPasswordsDrawerContent(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPasswordsDrawerContent(ThemeData theme) {
    final entries = [
      PasswordEntry(
        id: "1293A",
        service: "Chase",
        serviceType: "Banking",
        username: "Encrypto",
        creationDate: "2025-01-02",
      ),
      PasswordEntry(
        id: "1293A",
        service: "Chase",
        serviceType: "Banking",
        username: "Encrypto",
        creationDate: "2025-01-02",
      ),
      PasswordEntry(
        id: "12395G",
        service: "Qualstar",
        serviceType: "Banking",
        username: "Encrypto",
        creationDate: "2025-01-01",
      ),
      PasswordEntry(
        id: "030903MJ",
        service: "Extra Gum",
        serviceType: "Leisure",
        username: "GumOnMyFace",
        creationDate: "2003-06-29",
      ),
      PasswordEntry(
        id: "203902MHD",
        service: "Facebook",
        serviceType: "Leisure",
        username: "CharlieBitMe",
        creationDate: "2010-12-03",
      ),
      PasswordEntry(
        id: "2938JD1",
        service: "Federal Union",
        serviceType: "Banking",
        username: "Bankzilla991",
        creationDate: "2022-05-17",
      ),
      // ...
    ];
    return PasswordListView(
      passwordEntries: entries,
      onEntryTap: _onPasswordTap,
    );
  }

  void _onPasswordTap(PasswordEntry entry) {
    context.read<SnackBarProvider>().showMessage('Selected password: ${entry.service}');
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:passguard/frontend/screens/info_screen.dart';
// import 'package:passguard/frontend/screens/passwords_screen.dart';
// import 'package:passguard/frontend/screens/settings_screen.dart';
// import 'package:passguard/frontend/widgets/permanent_snackbar.dart';

// import 'package:provider/provider.dart';
// import 'package:passguard/frontend/widgets/info_drawer_content.dart';
// import 'package:passguard/frontend/providers/auth_provider.dart';
// import 'package:passguard/frontend/providers/snackbar_provider.dart';
// import 'package:passguard/frontend/theme/theme_config.dart';

// import 'package:passguard/frontend/widgets/password_list_view.dart';

// class MainApp extends StatefulWidget {
//   const MainApp({Key? key}) : super(key: key);

//   @override
//   State<MainApp> createState() => _MainAppState();
// }

// class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   // Two variables:
//   int? pinnedIndex; // Which tab is permanently pinned (only #1 in our scenario)
//   int? hoveredIndex; // The tab currently hovered (0 for Info, 1 for Passwords, etc.)
//   bool isDrawerHovered = false;
//   Timer? _closeTimer;

//   static const double _navRailWidth = 72;
//   static const double _drawerWidth = 250;
//   static const Duration _closeDelay = Duration(milliseconds: 200);

//   bool get isDesktop => MediaQuery.of(context).size.width > 600;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _closeTimer?.cancel();
//     _tabController.dispose();
//     super.dispose();
//   }

//   /// Which tab's drawer content do we display right now?
//   /// Priority: hoveredIndex -> pinnedIndex.
//   int? get displayedDrawerIndex => hoveredIndex ?? pinnedIndex;

//   /// Should we show the drawer at all?
//   /// We'll show it only if displayedDrawerIndex is 0 (Info) or 1 (Passwords).
//   bool get shouldShowDrawer {
//     final di = displayedDrawerIndex;
//     if (di == 0 || di == 1) {
//       return true;
//     }
//     return false;
//   }

//   /// Do we shift the main content? Only if the *displayed* drawer is Passwords (1).
//   bool get shouldShiftContent => pinnedIndex == 1; // displayedDrawerIndex == 1;
//   bool get shouldDoOtherStuff => false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: isDesktop
//           ? null
//           : AppBar(
//               title: const Text('Encryptilock'),
//               bottom: TabBar(
//                 controller: _tabController,
//                 tabs: const [
//                   Tab(icon: Icon(Icons.info), text: 'Info'),
//                   Tab(icon: Icon(Icons.lock), text: 'Passwords'),
//                   Tab(icon: Icon(Icons.settings), text: 'Settings'),
//                 ],
//               ),
//             ),
//       body: Stack(
//         children: [
//           if (isDesktop) ...[
//             // Shift content only if the Passwords drawer is displayed
//             Positioned(
//               left: _navRailWidth + (shouldShiftContent ? _drawerWidth : 0),
//               right: 0,
//               top: 0,
//               bottom: 0,
//               child: TabBarView(
//                 controller: _tabController,
//                 children: const [
//                   InfoScreen(),
//                   PasswordsScreen(),
//                   SettingsScreen(),
//                 ],
//               ),
//             ),
//             _buildExpandableDrawer(),
//             Positioned(
//               left: 0,
//               top: 0,
//               bottom: 0,
//               child: _buildNavigationRail(),
//             ),
//             // If you want the permanent bar to shift too, pass leftPaddingWhenDrawerOpen:
//             PermanentSnackBar(
//               leftPaddingWhenDrawerOpen: shouldDoOtherStuff ? _navRailWidth + 6 + _drawerWidth : _navRailWidth + 8,
//             ),
//           ] else ...[
//             // Mobile layout
//             TabBarView(
//               controller: _tabController,
//               children: const [
//                 InfoScreen(),
//                 PasswordsScreen(),
//                 SettingsScreen(),
//               ],
//             ),
//             const PermanentSnackBar(),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildNavigationRail() {
//     final theme = Theme.of(context);

//     return NavigationRail(
//       backgroundColor: theme.colorScheme.surface,
//       selectedIndex: _tabController.index,
//       onDestinationSelected: (index) {
//         setState(() {
//           if (index == 3) {
//             // If there's a 4th destination for logout
//             _appLogout(context);
//           } else {
//             // If user selects "Passwords" tab, we pin that tab
//             if (index == 1) {
//               pinnedIndex = 1; // permanently pinned
//             } else {
//               // For "Info" (0) or "Settings" (2),
//               // we do NOT want permanent pin
//               pinnedIndex = null;
//             }
//             hoveredIndex = null;
//             _tabController.animateTo(index);

//             // Optional: Show a snack
//             context.read<SnackBarProvider>().showMessage('Opened tab: $index');
//           }
//         });
//       },
//       destinations: [
//         _buildRailDestination(Icons.info, 'Info', 0),
//         _buildRailDestination(Icons.lock, 'Passwords', 1),
//         _buildRailDestination(Icons.settings, 'Settings', 2),
//         _buildLogoutRailDestination(),
//       ],
//       indicatorShape: const BeveledRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(4),
//           bottom: Radius.circular(4),
//         ),
//       ),
//     );
//   }

//   NavigationRailDestination _buildRailDestination(IconData icon, String label, int index) {
//     return NavigationRailDestination(
//       icon: SizedBox(
//         width: _navRailWidth,
//         child: MouseRegion(
//           onEnter: (_) {
//             // Only hover Info(0) or Passwords(1). Not Settings(2).
//             if (index == 0 || index == 1) {
//               _closeTimer?.cancel();
//               setState(() {
//                 hoveredIndex = index;
//               });
//             }
//           },
//           onExit: (_) => _startCloseTimer(),
//           child: Center(
//             child: Icon(
//               icon,
//               // Highlight the icon if pinned OR hovered
//               color: (hoveredIndex == index || pinnedIndex == index) ? Theme.of(context).colorScheme.primary : null,
//             ),
//           ),
//         ),
//       ),
//       label: Text(label),
//     );
//   }

//   NavigationRailDestination _buildLogoutRailDestination() {
//     return const NavigationRailDestination(
//       icon: Icon(Icons.power_settings_new),
//       label: Text('Logout'),
//     );
//   }

//   void _appLogout(BuildContext context) async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     await authProvider.logout();
//     SystemNavigator.pop();
//   }

//   /// If user is not hovered over the drawer area after a short delay,
//   /// revert hoveredIndex to null. We keep pinnedIndex if it's set to #1.
//   void _startCloseTimer() {
//     _closeTimer?.cancel();
//     _closeTimer = Timer(_closeDelay, () {
//       if (!mounted) return;
//       if (!isDrawerHovered) {
//         setState(() {
//           hoveredIndex = null;
//         });
//       }
//     });
//   }

//   Widget _buildExpandableDrawer() {
//     final theme = Theme.of(context);

//     return AnimatedPositioned(
//       duration: shouldShowDrawer ? const Duration(milliseconds: 200) : const Duration(milliseconds: 800),
//       curve: Curves.easeInOut,
//       // If showing drawer for Info or Passwords, place it flush.
//       // Otherwise hide it to the left
//       left: shouldShowDrawer ? _navRailWidth : _navRailWidth - _drawerWidth,
//       top: 0,
//       bottom: 0,
//       width: _drawerWidth,
//       child: MouseRegion(
//         onEnter: (_) {
//           _closeTimer?.cancel();
//           setState(() => isDrawerHovered = true);
//         },
//         onExit: (_) {
//           setState(() => isDrawerHovered = false);
//           _startCloseTimer();
//         },
//         child: Material(
//           elevation: 4,
//           color: theme.colorScheme.surface,
//           // If we want to show a drawer, check which index we are showing.
//           child: shouldShowDrawer && displayedDrawerIndex != null
//               ? Container(
//                   padding: const EdgeInsets.fromLTRB(3, 5, 3, 5),
//                   foregroundDecoration: BoxDecoration(
//                     border: Border(
//                       left: BorderSide(
//                         color: theme.colorScheme.primary.withOpacity(0.1),
//                         width: 5,
//                       ),
//                     ),
//                   ),
//                   child: _buildDrawerContent(displayedDrawerIndex!, theme),
//                 )
//               : const SizedBox.shrink(),
//         ),
//       ),
//     );
//   }

//   /// We only have drawer content for Info (0) and Passwords (1).
//   Widget _buildDrawerContent(int index, ThemeData theme) {
//     switch (index) {
//       case 0:
//         // Info drawer
//         return const InfoDrawerContent(websiteUrl: 'www.passguard9000.com');
//       case 1:
//         // Password drawer
//         return _buildPasswordsDrawerContent(theme);
//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   Widget _buildPasswordsDrawerContent(ThemeData theme) {
//     final entries = [
//       PasswordEntry(
//         id: "1293A",
//         service: "Chase",
//         serviceType: "Banking",
//         username: "Encrypto",
//         creationDate: "2025-01-02",
//       ),
//       // etc...
//     ];
//     return PasswordListView(
//       passwordEntries: entries,
//       onEntryTap: _onPasswordTap,
//     );
//   }

//   void _onPasswordTap(PasswordEntry entry) {
//     debugPrint("Selected password entry: ${entry.service}");
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:passguard/frontend/screens/info_screen.dart';
// import 'package:passguard/frontend/screens/passwords_screen.dart';
// import 'package:passguard/frontend/screens/settings_screen.dart';
// import 'package:passguard/frontend/widgets/permanent_snackbar.dart';

// import 'package:provider/provider.dart';
// import 'package:passguard/frontend/widgets/info_drawer_content.dart';
// import 'package:passguard/frontend/providers/auth_provider.dart';
// import 'package:passguard/frontend/providers/snackbar_provider.dart';
// import 'package:passguard/frontend/theme/theme_config.dart';

// import 'package:passguard/frontend/widgets/password_list_view.dart';

// class MainApp extends StatefulWidget {
//   const MainApp({Key? key}) : super(key: key);

//   @override
//   State<MainApp> createState() => _MainAppState();
// }

// class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   // --- Two separate variables:
//   int? pinnedIndex; // The *selected* tab that pins the drawer open
//   int? hoveredIndex; // The tab that is currently hovered, if any

//   bool isDrawerHovered = false;
//   Timer? _closeTimer;

//   static const double _navRailWidth = 72;
//   static const double _drawerWidth = 250;
//   static const Duration _closeDelay = Duration(milliseconds: 200);

//   bool get isDesktop => MediaQuery.of(context).size.width > 600;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _closeTimer?.cancel();
//     _tabController.dispose();
//     super.dispose();
//   }

//   /// Should we show the drawer at all?
//   /// We show it if pinnedIndex != null (a tab is selected)
//   /// OR we are actively hovering a tab/drawer.
//   bool get shouldShowDrawer {
//     return pinnedIndex != null || hoveredIndex != null || isDrawerHovered;
//   }

//   /// Which tab's content are we currently displaying in the drawer?
//   /// If there's a hoveredIndex, that takes priority.
//   /// Otherwise we use pinnedIndex.
//   int? get displayedDrawerIndex {
//     return hoveredIndex ?? pinnedIndex;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: isDesktop
//           ? null
//           : AppBar(
//               title: const Text('Encryptilock'),
//               bottom: TabBar(
//                 controller: _tabController,
//                 tabs: const [
//                   Tab(icon: Icon(Icons.info), text: 'Info'),
//                   Tab(icon: Icon(Icons.lock), text: 'Passwords'),
//                   Tab(icon: Icon(Icons.settings), text: 'Settings'),
//                 ],
//               ),
//             ),
//       body: Stack(
//         children: [
//           // If desktop, show rail + (possible) pinned drawer
//           if (isDesktop) ...[
//             // Shift the main content if the drawer is shown
//             Positioned(
//               left: _navRailWidth + (shouldShowDrawer ? _drawerWidth : 0),
//               right: 0,
//               top: 0,
//               bottom: 0,
//               child: TabBarView(
//                 controller: _tabController,
//                 children: const [
//                   InfoScreen(),
//                   PasswordsScreen(),
//                   SettingsPage(),
//                 ],
//               ),
//             ),
//             _buildExpandableDrawer(),
//             Positioned(
//               left: 0,
//               top: 0,
//               bottom: 0,
//               child: _buildNavigationRail(),
//             ),
//             PermanentSnackBar(leftPaddingWhenDrawerOpen: shouldShowDrawer ? _navRailWidth + 6 + _drawerWidth : _navRailWidth + 8),
//           ] else ...[
//             // MOBILE layout
//             TabBarView(
//               controller: _tabController,
//               children: const [
//                 InfoScreen(),
//                 PasswordsScreen(),
//                 SettingsPage(),
//               ],
//             ),
//             const PermanentSnackBar(),
//           ],

//           // Permanent snack bar pinned at bottom
//         ],
//       ),
//     );
//   }

//   Widget _buildNavigationRail() {
//     final theme = Theme.of(context);

//     return NavigationRail(
//       backgroundColor: theme.colorScheme.surfaceContainer,
//       selectedIndex: _tabController.index,
//       onDestinationSelected: (index) {
//         setState(() {
//           if (index == 3) {
//             _appLogout(context);
//           } else {
//             // When user actually selects a tab, we "pin" that index
//             if (index == 2) {
//               pinnedIndex = null;
//             } else {
//               pinnedIndex = index;
//             }
//             hoveredIndex = null;

//             _tabController.animateTo(index);

//             // Example: show a quick snack message
//             context.read<SnackBarProvider>().showMessage('Opened tab: $index');
//           }
//         });
//       },
//       destinations: [
//         _buildRailDestination(Icons.info, 'Info', 0),
//         _buildRailDestination(Icons.lock, 'Passwords', 1),
//         _buildRailDestination(Icons.settings, 'Settings', 2),
//         _buildLogoutRailDestination(),
//       ],
//       indicatorShape: const BeveledRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(4), bottom: Radius.circular(4)),
//       ),
//     );
//   }

//   NavigationRailDestination _buildRailDestination(IconData icon, String label, int index) {
//     return NavigationRailDestination(
//       icon: SizedBox(
//         width: _navRailWidth,
//         child: MouseRegion(
//           onEnter: (_) {
//             _closeTimer?.cancel();
//             setState(() {
//               if (index != 2) hoveredIndex = index;
//             });
//           },
//           onExit: (event) {
//             // If user exits the icon area, start the close timer
//             // (But if user moves into the drawer, we handle in _buildExpandableDrawer)
//             _startCloseTimer();
//           },
//           child: Center(
//             child: Icon(
//               icon,
//               color: (hoveredIndex == index || pinnedIndex == index) ? Theme.of(context).colorScheme.primary : null,
//             ),
//           ),
//         ),
//       ),
//       label: Text(label),
//     );
//   }

//   NavigationRailDestination _buildLogoutRailDestination() {
//     return const NavigationRailDestination(
//       icon: Icon(Icons.power_settings_new),
//       label: Text('Logout'),
//     );
//   }

//   void _appLogout(BuildContext context) async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     await authProvider.logout();
//     SystemNavigator.pop();
//   }

//   /// Start the close timer *only* if the user is not pinned to a tab (?)
//   /// Actually, if pinnedIndex is set, we don't want to close the drawer entirely.
//   /// But we *do* want to revert from hoveredIndex -> pinnedIndex if we are hovering
//   /// a different tab.
//   void _startCloseTimer() {
//     _closeTimer?.cancel();
//     _closeTimer = Timer(_closeDelay, () {
//       if (!mounted) return;

//       // If the mouse is not currently over the drawer...
//       if (!isDrawerHovered) {
//         setState(() {
//           // Clear the hoveredIndex, but keep pinnedIndex
//           hoveredIndex = null;
//         });
//       }
//     });
//   }

//   Widget _buildExpandableDrawer() {
//     final theme = Theme.of(context);

//     return AnimatedPositioned(
//       duration: shouldShowDrawer ? const Duration(milliseconds: 200) : const Duration(milliseconds: 800),
//       curve: Curves.easeInOut,
//       // If drawer is shown, place it flush with the nav rail. Otherwise move it left
//       left: shouldShowDrawer ? _navRailWidth : _navRailWidth - _drawerWidth,
//       top: 0,
//       bottom: 0,
//       width: _drawerWidth,
//       child: MouseRegion(
//         onEnter: (_) {
//           _closeTimer?.cancel();
//           setState(() => isDrawerHovered = true);
//         },
//         onExit: (_) {
//           setState(() => isDrawerHovered = false);
//           _startCloseTimer();
//         },
//         child: Material(
//           elevation: 4,
//           color: theme.colorScheme.surface,
//           child: shouldShowDrawer && displayedDrawerIndex != null
//               ? Container(
//                   padding: const EdgeInsets.fromLTRB(3, 5, 3, 5),
//                   foregroundDecoration: BoxDecoration(
//                     border: Border(
//                       left: BorderSide(
//                         color: theme.colorScheme.primary.withOpacity(0.1),
//                         width: 5,
//                       ),
//                     ),
//                   ),
//                   child: _buildDrawerContent(displayedDrawerIndex!, theme),
//                 )
//               : const SizedBox.shrink(),
//         ),
//       ),
//     );
//   }

//   Widget _buildDrawerContent(int index, ThemeData theme) {
//     switch (index) {
//       case 0:
//         return const InfoDrawerContent(websiteUrl: 'www.passguard9000.com');
//       case 1:
//         return _buildPasswordsDrawerContent(theme);
//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   Widget _buildPasswordsDrawerContent(ThemeData theme) {
//     final entries = [
//       PasswordEntry(
//         id: "1293A",
//         service: "Chase",
//         serviceType: "Banking",
//         username: "Encrypto",
//         creationDate: "2025-01-02",
//       ),
//       // ...
//     ];
//     return PasswordListView(
//       passwordEntries: entries,
//       onEntryTap: _onPasswordTap,
//     );
//   }

//   void _onPasswordTap(PasswordEntry entry) {
//     debugPrint("Selected password entry: ${entry.service}");
//   }
// }
// ------------------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------- ABOVE FUNCTIONS AS ASKED
// ------------------------------------------------------------------------------------------------------------------------------------

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:passguard/frontend/screens/info_screen.dart';
// import 'package:passguard/frontend/screens/passwords_screen.dart';
// import 'package:passguard/frontend/screens/settings_screen.dart';
// import 'package:passguard/frontend/widgets/permanent_snackbar.dart';

// import 'package:provider/provider.dart';
// import 'package:passguard/frontend/widgets/info_drawer_content.dart';
// import 'package:passguard/frontend/providers/auth_provider.dart';
// import 'package:passguard/frontend/providers/snackbar_provider.dart';
// import 'package:passguard/frontend/theme/theme_config.dart';

// import 'package:passguard/frontend/widgets/password_list_view.dart';

// class MainApp extends StatefulWidget {
//   const MainApp({Key? key}) : super(key: key);

//   @override
//   State<MainApp> createState() => _MainAppState();
// }

// class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool isIconHovered = false;
//   bool isDrawerHovered = false;
//   int? hoveredIndex;
//   int selectIndex = 0;
//   Timer? _closeTimer;

//   static const double _navRailWidth = 72;
//   static const double _drawerWidth = 250;
//   static const Duration _closeDelay = Duration(milliseconds: 200);

//   bool get isDrawerPinned => hoveredIndex == _tabController.index;
//   bool get shouldShowDrawer => isIconHovered || isDrawerHovered || isDrawerPinned;
//   // bool get shouldShowDrawer => (isIconHovered || isDrawerHovered) && hoveredIndex != null && hoveredIndex != _tabController.index;

//   @override
//   void initState() {
//     print("MainApp initializing");
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     print("MainApp disposing");
//     _closeTimer?.cancel();
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDesktop = MediaQuery.of(context).size.width > 600;

//     final snackBarProvider = context.watch<SnackBarProvider>();

//     return Scaffold(
//       appBar: isDesktop
//           ? null
//           : AppBar(
//               title: const Text('Encryptilock'),
//               bottom: TabBar(
//                 controller: _tabController,
//                 tabs: const [
//                   Tab(icon: Icon(Icons.info), text: 'Info'),
//                   Tab(icon: Icon(Icons.lock), text: 'Passwords'),
//                   Tab(icon: Icon(Icons.settings), text: 'Settings'),
//                 ],
//               ),
//             ),
//       body: Stack(
//         children: [
//           // If desktop, display your positioned TabBarView & drawer, etc.
//           if (isDesktop) ...[
//             Positioned(
//               left: _navRailWidth + (isDrawerPinned ? _drawerWidth : 0),
//               right: 0,
//               top: 0,
//               bottom: 0,
//               child: TabBarView(
//                 controller: _tabController,
//                 children: const [
//                   InfoScreen(),
//                   PasswordsScreen(),
//                   SettingsPage(),
//                 ],
//               ),
//             ),
//             _buildExpandableDrawer(theme),
//             Positioned(
//               left: 0,
//               top: 0,
//               bottom: 0,
//               child: _buildNavigationRail(theme),
//             ),
//             PermanentSnackBar(leftPaddingWhenDrawerOpen: shouldShowDrawer ? _navRailWidth + 6 + _drawerWidth : _navRailWidth + 8),
//           ]
//           // Otherwise, mobile layout with just TabBarView
//           else ...[
//             TabBarView(
//               controller: _tabController,
//               children: const [
//                 InfoScreen(),
//                 PasswordsScreen(),
//                 SettingsPage(),
//               ],
//             ),
//             PermanentSnackBar(),
//           ],

//           // Always show permanent snack bar at bottom
//         ],
//       ),
//     );
//   }

//   Widget _buildNavigationRail(ThemeData theme) {
//     return NavigationRail(
//       backgroundColor: theme.colorScheme.surfaceContainer,
//       selectedIndex: _tabController.index,
//       onDestinationSelected: (index) {
//         setState(() {
//           if (index == 3) {
//             _appLogout(context);
//           } else {
//             // print('setting selectIndex: $selectIndex');
//             // selectIndex = _tabController.index; // TODO trying to get nav drawer to stay expanded when on selected tab.
//             // hoveredIndex = null;
//             hoveredIndex = index;
//             isIconHovered = false;
//             isDrawerHovered = false;
//             _tabController.animateTo(index);
//           }
//         });
//       },
//       destinations: [
//         _buildRailDestination(Icons.info, 'Info', 0),
//         _buildRailDestination(Icons.lock, 'Passwords', 1),
//         _buildRailDestination(Icons.settings, 'Settings', 2),
//         _buildLogoutRailDestination(),
//       ],
//       indicatorShape: BeveledRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(4), bottom: Radius.circular(4))),
//     );
//   }

//   NavigationRailDestination _buildRailDestination(IconData icon, String label, int index) {
//     return NavigationRailDestination(
//       icon: SizedBox(
//         width: _navRailWidth, // Ensure full width
//         child: MouseRegion(
//           onEnter: (_) {
//             _closeTimer?.cancel();
//             setState(() {
//               hoveredIndex = index;
//               if (index != 2) isIconHovered = true; // index != Settings
//             });
//           },
//           onExit: (event) {
//             // Check if the mouse is moving towards the drawer
//             if (event.position.dx > _navRailWidth - 10) {
//               // Moving towards drawer - don't start close timer
//               setState(() {
//                 isIconHovered = false;
//               });
//             } else {
//               // Moving away from drawer - start close timer
//               setState(() {
//                 isIconHovered = false;
//               });
//               _startCloseTimer();
//             }
//           },
//           child: Center(
//             child: Icon(icon, color: hoveredIndex == index ? Theme.of(context).colorScheme.primary : null),
//           ),
//         ),
//       ),
//       label: Text(label),
//     );
//   }

//   // Add a new function to build the logout destination
//   NavigationRailDestination _buildLogoutRailDestination() {
//     return NavigationRailDestination(
//       icon: Icon(Icons.power_settings_new),
//       label: const Text('Logout'),
//     );
//   }

//   void _appLogout(BuildContext context) async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     await authProvider.logout();
//     print("logging out and closing the app");
//     SystemNavigator.pop();
//   }

//   void _startCloseTimer() {
//     _closeTimer?.cancel();
//     if (isDrawerPinned) return; // if the tabs selected, we don't want to close it.
//     _closeTimer = Timer(_closeDelay, () {
//       if (!mounted) return;
//       if (!isDrawerHovered) {
//         setState(() {
//           hoveredIndex = null;
//         });
//       }
//     });
//   }

  // Widget _buildExpandableDrawer(ThemeData theme) {
  //   return AnimatedPositioned(
  //     duration: shouldShowDrawer ? const Duration(milliseconds: 200) : const Duration(milliseconds: 800), // Made closing animation faster
  //     curve: Curves.easeInOut,
      // left: shouldShowDrawer ? _navRailWidth + 5 : -_drawerWidth,
  //     top: 0,
  //     bottom: 0,
  //     width: _drawerWidth,
  //     child: MouseRegion(
  //       onEnter: (_) {
  //         _closeTimer?.cancel();
  //         setState(() => isDrawerHovered = true);
  //       },
  //       onExit: (_) {
  //         setState(() {
  //           isDrawerHovered = false;
  //         });
  //         _startCloseTimer();
  //       },
  //       child: Material(
  //         elevation: 4,
  //         color: theme.colorScheme.surface,
  //         child: shouldShowDrawer
  //             ? Container(
  //                 padding: EdgeInsets.fromLTRB(3, 5, 3, 5),
  //                 foregroundDecoration: BoxDecoration(border: Border(left: BorderSide(color: theme.colorScheme.primary.withOpacity(0.1), width: 5))),
  //                 child: _buildDrawerContent(hoveredIndex!, theme),
  //               )
  //             : const SizedBox.shrink(),
  //       ),
  //     ),
  //   );
  // }

//   Widget _buildDrawerContent(int index, ThemeData theme) {
//     switch (index) {
//       case 0:
//         return const InfoDrawerContent(websiteUrl: 'www.passguard9000.com');
//       case 1:
//         return _buildPasswordsDrawerContent(theme);
//       // case 2:
//       //   return _buildSettingsDrawerContent(theme);
//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   Widget _buildPasswordsDrawerContent(ThemeData theme) {
//     List<PasswordEntry> passwordEntries = [
//       PasswordEntry(
//         id: "1293A",
//         service: "Chase",
//         serviceType: "Banking",
//         username: "Encrypto",
//         creationDate: "2025-01-02",
//       ),
//       PasswordEntry(
//         id: "12395G",
//         service: "Qualstar",
//         serviceType: "Banking",
//         username: "Encrypto",
//         creationDate: "2025-01-01",
//       ),
//       PasswordEntry(
//         id: "030903MJ",
//         service: "Extra Gum",
//         serviceType: "Leisure",
//         username: "GumOnMyFace",
//         creationDate: "2003-06-29",
//       ),
//       PasswordEntry(
//         id: "203902MHD",
//         service: "Facebook",
//         serviceType: "Leisure",
//         username: "CharlieBitMe",
//         creationDate: "2010-12-03",
//       ),
//       PasswordEntry(
//         id: "2938JD1",
//         service: "Federal Union",
//         serviceType: "Banking",
//         username: "Bankzilla991",
//         creationDate: "2022-05-17",
//       ),
//     ];
//     return PasswordListView(passwordEntries: passwordEntries, onEntryTap: _onPasswordTap);
//   }

//   void _onPasswordTap(PasswordEntry entry) {
//     print("received entry: ${entry.service}");
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
