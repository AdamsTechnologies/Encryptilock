import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passguard/frontend/providers/auth_provider.dart';
import 'package:passguard/frontend/providers/settings_provider.dart';
import 'package:passguard/frontend/screens/login_screen.dart';

class IdleTimeoutProvider with ChangeNotifier, WidgetsBindingObserver {
  Timer? _inactivityTimer;
  final GlobalKey<NavigatorState> navigatorKey;
  SettingsProvider? settingsProvider;
  AuthProvider? authProvider;
  bool isTracking = false;
  bool _isInitialized = false;
  int? _lastIdleTimeout;

  IdleTimeoutProvider({required this.navigatorKey});

  void startTracking(BuildContext context) {
    if (_isInitialized) return;

    print("Starting idle timeout tracking");
    WidgetsBinding.instance.addObserver(this);
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);

    _syncIdleTimeout(); // Initial sync
    settingsProvider!.addListener(_settingsListener); // Start listening

    isTracking = true;
    _isInitialized = true;
  }

  void stopTracking() {
    if (!_isInitialized) return;

    print("Stopping idle timeout tracking");
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    settingsProvider?.removeListener(_settingsListener); // Stop listening
    isTracking = false;
    _isInitialized = false;
  }
  
  void _settingsListener() {
    _syncIdleTimeout();
  }

  void _syncIdleTimeout() {
    final currentIdleTimeout = settingsProvider?.idleTimeout;
    if (currentIdleTimeout != _lastIdleTimeout) {
      _lastIdleTimeout = currentIdleTimeout;
      print("idleTimeout changed, syncing timer to: $currentIdleTimeout");
      _resetTimer();
    }
  }

  void _resetTimer() {
    if (!isTracking) return;

    _inactivityTimer?.cancel();
    final idleTimeout = settingsProvider?.idleTimeout ?? 1;
    print("Resetting timer with timeout: $idleTimeout minutes");

    _inactivityTimer = Timer(Duration(minutes: idleTimeout), () {
      print("Timer expired - executing timeout");
      _onTimeout();
    });
  }

  void resetOnInteraction() {
    print("User interaction detected");
    if (isTracking) {
      _resetTimer();
    }
  }

  Future<void> _onTimeout() async {
    if (!isTracking) return;
    
    print("Timeout occurred - logging out");
    try {
      await authProvider?.logout();
      if (navigatorKey.currentState?.mounted ?? false) {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } catch (e) {
      print("Error during timeout logout: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("App lifecycle state changed to: $state");
    if (state == AppLifecycleState.resumed) {
      _resetTimer();
    } else if (state == AppLifecycleState.paused) {
      _inactivityTimer?.cancel();
    }
  }
}
