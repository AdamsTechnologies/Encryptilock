import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// import 'package:encryptilock/frontend/theme/theme_config.dart';
// import 'package:encryptilock/backend/abstracts/abstract_objects.dart';
// import 'package:encryptilock/frontend/providers/snackbar_provider.dart';
// import 'package:encryptilock/frontend/widgets/info_drawer_content.dart';
// import 'package:encryptilock/frontend/widgets/password_create_edit_page.dart';

import 'package:encryptilock/frontend/providers/auth_provider.dart';
import 'package:encryptilock/frontend/providers/password_provider.dart';

import 'package:encryptilock/frontend/screens/info_screen.dart';
import 'package:encryptilock/frontend/screens/passwords_screen.dart';
import 'package:encryptilock/frontend/screens/settings_screen.dart';

import 'package:encryptilock/frontend/widgets/permanent_snackbar.dart';
import 'package:encryptilock/frontend/widgets/password_list_view.dart';

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

  bool get isDesktop => MediaQuery.of(context).size.width > 750;

  @override
  void initState() {
    super.initState();
    // 4 tabs -> Info(0), Passwords(1), Settings(2), Logout(3)
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  int? get displayedDrawerIndex {
    if (pinnedIndex == 1) {
      return 1;
    }
    return hoveredIndex;
  }

  bool get shouldShowDrawer {
    final di = displayedDrawerIndex;
    // return di == 0 || di == 1;
    return di == 1;
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
              // title: const Text('Encryptilock'),
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
            Positioned(
              left: _navRailWidth,
              right: 0,
              top: 0,
              bottom: 0,
              child: TabBarView(
                controller: _tabController,
                children: [
                  Padding(padding: EdgeInsets.only(), child: const InfoScreen()),
                  Padding(padding: EdgeInsets.only(left: _drawerWidth), child: const PasswordsScreen()), // left: shouldShiftContent ? _drawerWidth : 0
                  Padding(padding: EdgeInsets.only(), child: const SettingsScreen()),
                ],
              ),
            ),
            PermanentSnackBar(
              // height: 30.0,
              backgroundColor: theme.colorScheme.surface,
            ),
            _buildExpandableDrawer(),
            // The nav rail pinned at left
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildNavigationRail(),
            ),
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
        _buildRailDestination(Icons.power_settings_new, "Logout", 3),
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
            // Let all icons highlight on hover
            _closeTimer?.cancel();
            setState(() => hoveredIndex = index);
          },
          onExit: (_) {
            _startCloseTimer();
          },
          child: Center(
            child: Icon(
              icon,
              color: _iconColorFor(index), // see helper below
            ),
          ),
        ),
      ),
      label: Text(label),
    );
  }

  /// Helper to decide an icon’s color:
  Color? _iconColorFor(int index) {
    final isSelected = (_tabController.index == index);
    final isPinned = (pinnedIndex == index);
    final isHovered = (hoveredIndex == index);

    return (isSelected || isPinned || isHovered) ? Theme.of(context).colorScheme.primary : null;
  }

  void _appLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    SystemNavigator.pop();
  }

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
      // case 0:
      //   // Info drawer content
      //   return const InfoDrawerContent(websiteUrl: 'www.passguard9000.com');
      case 1:
        // Password drawer content
        return _buildPasswordsDrawerContent(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPasswordsDrawerContent(ThemeData theme) {
    return PasswordListView(
      onItemSelected: (int itemSelect) {
        // itemSelect of 0 == a password list item was selected, just open the passwordScreen.
        // itemSelect of 1 == the Create new password button was selected.
        pinnedIndex = 1;
        _tabController.index = 1;
        if (itemSelect == 1) {
          final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
          passwordProvider.setMode('create');
        }
      },
    );
  }
}
