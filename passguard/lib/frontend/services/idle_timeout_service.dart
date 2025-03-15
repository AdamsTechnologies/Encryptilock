import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Encryptilock/frontend/providers/auth_provider.dart';
import 'package:Encryptilock/frontend/providers/settings_provider.dart';

// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:Encryptilock/frontend/screens/login_screen.dart';

class IdleTimeoutService with ChangeNotifier {
  AuthProvider? _auth;
  SettingsProvider? _settings;
  Timer? _timer;
  bool _active = false; // Whether idle monitoring is active

  // Called by the ProxyProvider to wire references:
  void configure({
    required AuthProvider authProvider,
    required SettingsProvider settingsProvider,
  }) {
    _auth = authProvider;
    _settings = settingsProvider;

    // Remove old listeners if any
    _auth!.removeListener(_onAuthChanged);
    // Add a new one
    _auth!.addListener(_onAuthChanged);
    // Re-check current login state immediately
    _onAuthChanged();
  }

  void _onAuthChanged() {
    if (_auth?.isLoggedIn == true && !_active) {
      _startMonitoring();
    } else if (_auth?.isLoggedIn == false && _active) {
      _stopMonitoring();
    }
  }

  // User interacted => reset timer
  void resetTimer() {
    // Only if user is logged in & active
    if (_auth?.isLoggedIn == true && _active) {
      _timer?.cancel(); // why cancel? oh maybe cancel any existing timers.
      final idleMins = _settings?.idleTimeout ?? 5;
      _timer = Timer(Duration(minutes: idleMins), _onTimeout);
    }
  }

  // Start the idle timer if not started
  void _startMonitoring() {
    _active = true;
    resetTimer(); // set the timer now
  }

  // Stop idle timer
  void _stopMonitoring() {
    _active = false;
    _timer?.cancel();
    _timer = null;
  }

  // Called when timer fires => log out
  void _onTimeout() {
    if (_auth == null) return;
    if (_auth!.isLoggedIn) {
      _auth!.logout(); // or await if async
    }
    _stopMonitoring();
  }
}
