import 'dart:async';
import 'package:encryptilock/frontend/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:encryptilock/frontend/providers/auth_provider.dart';
import 'package:encryptilock/frontend/providers/password_provider.dart';
import 'package:encryptilock/frontend/providers/document_provider.dart';

import 'package:encryptilock/frontend/screens/home_screen.dart';
import 'package:encryptilock/frontend/screens/info_screen.dart';
import 'package:encryptilock/frontend/screens/passwords_screen.dart';
import 'package:encryptilock/frontend/screens/settings_screen.dart';

import 'package:encryptilock/frontend/widgets/permanent_snackbar.dart';
import 'package:encryptilock/frontend/widgets/password_list_view.dart';
import 'package:encryptilock/frontend/widgets/document_list_view.dart';

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _hoverDelayTimer;
  int? previewHoveredIndex;
  int? pinnedIndex;
  int? hoveredIndex;
  bool isDrawerHovered = false;
  Timer? _closeTimer;

  static const double _navRailWidth = 72;
  // static const double _drawerWidth = 250;
  double get _drawerWidth {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth * 0.25).clamp(125.0, 256.0);
  }

  static const Duration _closeDelay = Duration(milliseconds: 200);

  bool get isDesktop => MediaQuery.of(context).size.width > 750;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Now 4 tabs: Home, Passwords, Settings, Info
  }

  @override
  void dispose() {
    _hoverDelayTimer?.cancel();
    _closeTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }
  // @override
  // void dispose() {
  //   _closeTimer?.cancel();
  //   _hoverDelayTimer?.cancel();
  //   _tabController.dispose();
  //   super.dispose();
  // }
  // @override
  // void dispose() {
  //   _closeTimer?.cancel();
  //   _tabController.dispose();
  //   super.dispose();
  // }

  int? get displayedDrawerIndex {
    if (pinnedIndex == 1 || pinnedIndex == 3) return pinnedIndex;
    if (hoveredIndex == 1 || hoveredIndex == 3) return hoveredIndex;
    return null;
  }

  bool get shouldShowDrawer => displayedDrawerIndex != null;
  bool get shouldShiftContent => pinnedIndex == 1 || pinnedIndex == 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.power_settings_new),
                  tooltip: 'Logout',
                  onPressed: () => _appLogout(context),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                onTap: (index) {
                  // if (index == 0) {
                  //   final docsProvider = Provider.of<DocProvider>(context, listen: false);
                  //   docsProvider.clearSelection();
                  // }
                },
                tabs: const [
                  Tab(icon: Icon(Icons.home), text: 'Home'),
                  Tab(icon: Icon(Icons.lock), text: 'Passwords'),
                  Tab(icon: Icon(Icons.settings), text: 'Settings'),
                  Tab(icon: Icon(Icons.info_outline), text: 'Info'),
                ],
              ),
            ),
      body: Stack(
        children: [
          if (isDesktop) ...[
            Positioned(
              left: _navRailWidth,
              right: 0,
              top: 0,
              bottom: 0,
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(), // ← disables swipe/scroll nav
                children: [
                  const HomeScreen(),
                  Padding(
                    // padding: const EdgeInsets.only(left: _drawerWidth),
                    padding: EdgeInsets.only(left: _drawerWidth),
                    child: const PasswordsScreen(),
                  ),
                  const SettingsScreen(),
                  InfoScreen(
                    isDrawerPinned: pinnedIndex == 3,
                    drawerWidth: _drawerWidth,
                  ),
                ],
              ),
            ),
            PermanentSnackBar(backgroundColor: theme.colorScheme.surface),
            _buildExpandableDrawer(),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildNavigationRail(),
            ),
          ] else ...[
            TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // Optional: only if you want to disable swipe on mobile too
              children: [
                const HomeScreen(),
                const PasswordsScreen(),
                const SettingsScreen(),
                InfoScreen(isDrawerPinned: false, drawerWidth: _drawerWidth),
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
          if (index == 4) {
            _appLogout(context);
          } else {
            final prevIndex = _tabController.index;
            _tabController.animateTo(index);

            if (index == 3 && prevIndex != 3) {
              Provider.of<DocProvider>(context, listen: false).clearSelection();
            }

            pinnedIndex = (index == 1 || index == 3) ? index : null;
            hoveredIndex = null;
          }
        });
      },
      destinations: [
        _buildRailDestination(Icons.home, 'Home', 0),
        _buildRailDestination(Icons.lock, 'Passwords', 1),
        _buildRailDestination(Icons.settings, 'Settings', 2),
        _buildRailDestination(Icons.info_outline, 'User Manual', 3),
        _buildRailDestination(Icons.power_settings_new, 'Logout', 4),
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
            previewHoveredIndex = index;
            _hoverDelayTimer?.cancel();
            _hoverDelayTimer = Timer(const Duration(milliseconds: 250), () {
              if (!mounted) return;
              setState(() => hoveredIndex = index);
            });
            setState(() {}); // for previewHoveredIndex
          },
          onExit: (_) {
            _hoverDelayTimer?.cancel();
            setState(() {
              previewHoveredIndex = null;
            });
            _startCloseTimer();
          },
          child: Center(
            child: Icon(icon, color: _iconColorFor(index)),
          ),
        ),
      ),
      label: Text(label),
    );
  }
  // NavigationRailDestination _buildRailDestination(IconData icon, String label, int index) {
  //   return NavigationRailDestination(
  //     icon: SizedBox(
  //       width: _navRailWidth,
  //       child: MouseRegion(
  //         onEnter: (_) {
  //           _hoverDelayTimer?.cancel();
  //           _hoverDelayTimer = Timer(const Duration(milliseconds: 250), () {
  //             if (!mounted) return;
  //             setState(() => hoveredIndex = index);
  //           });
  //         },
  //         onExit: (_) {
  //           _hoverDelayTimer?.cancel();
  //           _startCloseTimer();
  //         },
  //         child: Center(
  //           child: Icon(icon, color: _iconColorFor(index)),
  //         ),
  //       ),
  //     ),
  //     label: Text(label),
  //   );
  // }
  // NavigationRailDestination _buildRailDestination(IconData icon, String label, int index) {
  //   return NavigationRailDestination(
  //     icon: SizedBox(
  //       width: _navRailWidth,
  //       child: MouseRegion(
  //         onEnter: (_) {
  //           _closeTimer?.cancel();
  //           setState(() => hoveredIndex = index);
  //         },
  //         onExit: (_) => _startCloseTimer(),
  //         child: Center(
  //           child: Icon(icon, color: _iconColorFor(index)),
  //         ),
  //       ),
  //     ),
  //     label: Text(label),
  //   );
  // }

  Color? _iconColorFor(int index) {
    final isSelected = (_tabController.index == index);
    final isPinned = (pinnedIndex == index);
    final isHovered = (previewHoveredIndex == index);
    return (isSelected || isPinned || isHovered) ? Theme.of(context).colorScheme.primary : null;
  }
  // Color? _iconColorFor(int index) {
  //   final isSelected = (_tabController.index == index);
  //   final isPinned = (pinnedIndex == index);
  //   final isHovered = (hoveredIndex == index);
  //   return (isSelected || isPinned || isHovered) ? Theme.of(context).colorScheme.primary : null;
  // }

  void _appLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingProvider = Provider.of<SettingsProvider>(context, listen: false);
    final clearOnLogout = settingProvider.clearFiltersOnLogout;
    if (clearOnLogout == true) {
      await settingProvider.clearCategoryFilters();
    }

    await authProvider.logout();
    SystemNavigator.pop();
  }

  void _startCloseTimer() {
    _closeTimer?.cancel();
    _closeTimer = Timer(_closeDelay, () {
      if (!mounted) return;
      if (!isDrawerHovered) {
        setState(() => hoveredIndex = null);
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
          child: displayedDrawerIndex == null
              ? const SizedBox.shrink()
              : Container(
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
                ),
        ),
      ),
    );
  }

  Widget _buildDrawerContent(int index, ThemeData theme) {
    switch (index) {
      case 1:
        return PasswordListView(
          onItemSelected: (int itemSelect) {
            pinnedIndex = 1;
            _tabController.index = 1;
            if (itemSelect == 1) {
              Provider.of<PasswordProvider>(context, listen: false).resetToCreateMode();
            }
          },
        );
      case 3:
        return DocListView(
          onItemSelected: (int itemSelect) {
            pinnedIndex = 3;
            _tabController.index = 3;
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
