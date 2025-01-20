import 'package:flutter/material.dart';
import 'dart:async';
import 'package:passguard/frontend/screens/info_screen.dart';
import 'package:passguard/frontend/screens/passwords_screen.dart';
import 'package:passguard/frontend/screens/settings_screen.dart';
import 'package:passguard/frontend/theme/theme_config.dart';

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isIconHovered = false;
  bool isDrawerHovered = false;
  int? hoveredIndex;
  Timer? _closeTimer;
  
  static const double _navRailWidth = 72;
  static const double _drawerWidth = 250;
  static const Duration _closeDelay = Duration(milliseconds: 200);

  bool get shouldShowDrawer => (isIconHovered || isDrawerHovered) && 
                             hoveredIndex != null && 
                             hoveredIndex != _tabController.index;

  @override
  void initState() {
    print("MainApp initializing");
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    print("MainApp disposing");
    _closeTimer?.cancel();
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
                Positioned(
                  left: _navRailWidth,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      InfoScreen(),
                      PasswordsScreen(),
                      SettingsPage(),
                    ],
                  ),
                ),
                _buildExpandableDrawer(theme),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: _buildNavigationRail(theme),
                ),
              ],
            )
          : TabBarView(
              controller: _tabController,
              children: const [
                InfoScreen(),
                PasswordsScreen(),
                SettingsPage(),
              ],
            ),
    );
  }

  Widget _buildNavigationRail(ThemeData theme) {
    return NavigationRail(
      backgroundColor: theme.colorScheme.surfaceContainer,
      selectedIndex: _tabController.index,
      onDestinationSelected: (index) {
        setState(() {
          hoveredIndex = null;
          isIconHovered = false;
          isDrawerHovered = false;
          _tabController.animateTo(index);
        });
      },
      destinations: [
        _buildRailDestination(Icons.info, 'Info', 0),
        _buildRailDestination(Icons.lock, 'Passwords', 1),
        _buildRailDestination(Icons.settings, 'Settings', 2),
      ],
      indicatorShape: BeveledRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(4),
          bottom: Radius.circular(4)
        )
      ),
    );
  }

  NavigationRailDestination _buildRailDestination(IconData icon, String label, int index) {
    return NavigationRailDestination(
      icon: SizedBox(
        width: _navRailWidth, // Ensure full width
        child: MouseRegion(
          onEnter: (_) {
            _closeTimer?.cancel();
            setState(() {
              hoveredIndex = index;
              if (index != 0) isIconHovered = true; // TODO update the index if we add a icon at top.
            });
          },
          onExit: (event) {
            // Check if the mouse is moving towards the drawer
            if (event.position.dx > _navRailWidth - 10) {
              // Moving towards drawer - don't start close timer
              setState(() {
                isIconHovered = false;
              });
            } else {
              // Moving away from drawer - start close timer
              setState(() {
                isIconHovered = false;
              });
              _startCloseTimer();
            }
          },
          child: Center(
            child: Icon(
              icon,
              color: hoveredIndex == index ? Theme.of(context).colorScheme.primary : null
            ),
          ),
        ),
      ),
      label: Text(label),
    );
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

  Widget _buildExpandableDrawer(ThemeData theme) {
    return AnimatedPositioned(
      duration: shouldShowDrawer 
          ? const Duration(milliseconds: 200) 
          : const Duration(milliseconds: 800), // Made closing animation faster
      curve: Curves.easeInOut,
      left: shouldShowDrawer ? _navRailWidth+5 : -_drawerWidth,
      top: 0,
      bottom: 0,
      width: _drawerWidth,
      child: MouseRegion(
        onEnter: (_) {
          _closeTimer?.cancel();
          setState(() => isDrawerHovered = true);
        },
        onExit: (_) {
          setState(() {
            isDrawerHovered = false;
          });
          _startCloseTimer();
        },
        child: Material(
          elevation: 4,
          color: theme.colorScheme.surface,
          child: shouldShowDrawer
              ? Container(
                  padding: EdgeInsets.fromLTRB(3, 5, 3, 5),
                  foregroundDecoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        width: 5
                      )
                    )
                  ),
                  child: _buildDrawerContent(hoveredIndex!, theme),
                )
              : const SizedBox.shrink(),
        ),
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
