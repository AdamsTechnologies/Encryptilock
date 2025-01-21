import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:passguard/frontend/screens/info_screen.dart';
import 'package:passguard/frontend/screens/passwords_screen.dart';
import 'package:passguard/frontend/screens/settings_screen.dart';


import 'package:provider/provider.dart';
import 'package:passguard/frontend/widgets/info_drawer_content.dart';
import 'package:passguard/frontend/providers/auth_provider.dart';
import 'package:passguard/frontend/theme/theme_config.dart';

import 'package:passguard/frontend/widgets/password_list_view.dart';

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
  int selectIndex = 0;
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
          // print('setting selectIndex: $selectIndex');
          // selectIndex = _tabController.index; // TODO trying to get nav drawer to stay expanded when on selected tab.
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
              if (index != 2) isIconHovered = true; // index != Settings
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

  void _launchWebsite() async {
    Uri url = Uri.https('www.passguard9000.com', '');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
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
      case 0:
        return _buildInfoDrawerContent(theme);
      case 1:
        return _buildPasswordsDrawerContent(theme);
      case 2:
        return _buildSettingsDrawerContent(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInfoDrawerContent(ThemeData theme) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.web_asset),
          title: const Text('Encryptilock Website'), // <-- website link
          onTap: () {_launchWebsite();},
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: const Text('Logout'),
          subtitle: const Text('save and logout'),
          onTap: () {
            // TODO handle logout
            print('logging out - actually needs implemented.');
          },
        ),
      ],
    );
  }

  Widget _buildPasswordsDrawerContent(ThemeData theme) {
    List<PasswordEntry> passwordEntries = [
      PasswordEntry(
        id:"1293A",
        service:"Chase",
        serviceType:"Banking",
        username:"Encrypto",
        creationDate:"2025-01-02",
      ),
      PasswordEntry(
        id:"12395G",
        service:"Qualstar",
        serviceType:"Banking",
        username:"Encrypto",
        creationDate:"2025-01-01",
      ),
      PasswordEntry(
        id:"030903MJ",
        service:"Extra Gum",
        serviceType:"Leisure",
        username:"GumOnMyFace",
        creationDate:"2003-06-29",
      ),
      PasswordEntry(
        id:"203902MHD",
        service:"Facebook",
        serviceType:"Leisure",
        username:"CharlieBitMe",
        creationDate:"2010-12-03",
      ),
      PasswordEntry(
        id:"2938JD1",
        service:"Federal Union",
        serviceType:"Banking",
        username:"Bankzilla991",
        creationDate:"2022-05-17",
      ),
    ];
    return PasswordListView(passwordEntries: passwordEntries, onEntryTap: _onPasswordTap);
  }
  void _onPasswordTap(PasswordEntry entry) {

    print("received entry: ${entry.service}");
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
