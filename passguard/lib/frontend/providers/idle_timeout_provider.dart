import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passguard/frontend/providers/auth_provider.dart';
import 'package:passguard/frontend/providers/settings_provider.dart';
import 'package:passguard/frontend/screens/login_screen.dart';

class IdleTimeoutProvider with ChangeNotifier, WidgetsBindingObserver {
  Timer? _inactivityTimer;
  final GlobalKey<NavigatorState> navigatorKey;
  late final SettingsProvider settingsProvider;
  late final AuthProvider authProvider;

  IdleTimeoutProvider({required this.navigatorKey});

  /// Starts tracking idle timeout and observes app lifecycle changes.
  void startTracking(BuildContext context) {
    WidgetsBinding.instance.addObserver(this);
    // Retrieve providers without listening to changes.
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    _resetTimer();
  }

  /// Stops tracking idle timeout and removes app lifecycle observer.
  void stopTracking() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
  }

  /// Resets the inactivity timer.
  void _resetTimer() {
    _inactivityTimer?.cancel();
    final idleTimeout = settingsProvider.idleTimeout;
    _inactivityTimer = Timer(Duration(minutes: idleTimeout), _onTimeout);
  }

  /// Public method to reset the timer on user interaction.
  void resetOnInteraction() {
    _resetTimer();
  }

  /// Called when the user exceeds the idle timeout duration.
  Future<void> _onTimeout() async {
    // Perform logout via AuthProvider.
    await authProvider.logout();
    // Navigate to the login screen using the global navigator key.
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  /// Handle app lifecycle state changes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resetTimer(); // Reset timer when app is resumed.
    } else if (state == AppLifecycleState.paused) {
      _inactivityTimer?.cancel(); // Cancel timer when app is paused.
    }
  }
}
