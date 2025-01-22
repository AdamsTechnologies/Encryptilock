import 'dart:async';
import 'package:flutter/material.dart';
import 'package:passguard/frontend/providers/auth_provider.dart';
import 'package:passguard/frontend/providers/settings_provider.dart';

// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:passguard/frontend/screens/login_screen.dart';

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
    print("IdleTimeoutService: configure executed.");
    _auth = authProvider;
    _settings = settingsProvider;

    // Remove old listeners if any
    print("IdleTimeoutService: configure: removing any listeners.");
    _auth!.removeListener(_onAuthChanged);
    // Add a new one
    print("IdleTimeoutService: configure: initializing new listener.");
    _auth!.addListener(_onAuthChanged);
    // Re-check current login state immediately
    print("IdleTimeoutService: configure: immediately checking state.");
    _onAuthChanged();
  }

  void _onAuthChanged() {
    print("_onAuthChanged: checking states.");
    print("_onAuthChanged: _auth.isLoggedIn= ${_auth?.isLoggedIn}:_active=$_active.");
    if (_auth?.isLoggedIn == true && !_active) {
      print("_onAuthChanged: start monitoring.");
      _startMonitoring();
    } else if (_auth?.isLoggedIn == false && _active) {
      print("_onAuthChanged: stop monitoring.");
      _stopMonitoring();
    }
  }

  // User interacted => reset timer
  void resetTimer() {
    print("IdleTimeoutService: resetTimer executed");
    // Only if user is logged in & active
    print("_onAuthChanged: _auth.isLoggedIn= ${_auth?.isLoggedIn}:_active=$_active.");
    if (_auth?.isLoggedIn == true && _active) {
      print("IdleTimeoutService: resetTimer timer cancel");
      _timer?.cancel(); // why cancel? oh maybe cancel any existing timers.
      final idleMins = _settings?.idleTimeout ?? 5;
      print("IdleTimeoutService: resetTimer idleMins=$idleMins");
      _timer = Timer(Duration(minutes: idleMins), _onTimeout);
    }
  }

  // Start the idle timer if not started
  void _startMonitoring() {
    print("IdleTimeoutService: start monitoring.");
    _active = true;
    resetTimer(); // set the timer now
  }

  // Stop idle timer
  void _stopMonitoring() {
    print("IdleTimeoutService: stop monitoring.");
    _active = false;
    _timer?.cancel();
    _timer = null;
  }

  // Called when timer fires => log out
  void _onTimeout() {
    print("IdleTimeoutService: timeout conditions met.");
    if (_auth == null) return;
    if (_auth!.isLoggedIn) {
      print("IdleTimeoutService: logging out");
      _auth!.logout(); // or await if async
    }
    _stopMonitoring();
  }
}


// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:passguard/frontend/providers/auth_provider.dart';
// import 'package:passguard/frontend/screens/login_screen.dart';
// import 'package:passguard/frontend/providers/settings_provider.dart';

// class IdleTimeoutService {
//   Timer? _timer;
//   final GlobalKey<NavigatorState> navigatorKey;
//   final AuthProvider authProvider;
//   final SettingsProvider settingsProvider;
//   bool _isLoggedIn = false; // Track login status internally
//   int? _lastIdleTimeout;

//   IdleTimeoutService({
//     required this.navigatorKey,
//     required this.authProvider,
//     required this.settingsProvider,
//   }) {
//     // Listen to auth provider changes
//     authProvider.addListener(_authListener);
//     settingsProvider.addListener(_settingsListener);
//   }

//   void _authListener() {
//     if (authProvider.isLoggedIn && !_isLoggedIn) {
//       _startTimer();
//     } else if (!authProvider.isLoggedIn && _isLoggedIn){
//       _stopTimer();
//     }
//     _isLoggedIn = authProvider.isLoggedIn;
//   }

//   void _settingsListener() {
//     _syncIdleTimeout();
//   }

//   void _syncIdleTimeout() {
//     final currentIdleTimeout = settingsProvider.idleTimeout;
//     if (currentIdleTimeout != _lastIdleTimeout) {
//       _lastIdleTimeout = currentIdleTimeout;
//       print("idleTimeout changed, syncing timer to: $currentIdleTimeout");
//       _startTimer();
//     }
//   }

//   void _startTimer() {
//     _timer?.cancel(); // Cancel any existing timer
//     if (!authProvider.isLoggedIn) return; // Don't start if not logged in

//     final idleTimeout = settingsProvider.idleTimeout;
//     _timer = Timer(Duration(minutes: idleTimeout), _onTimeout);
//     print("Starting idle timer for $idleTimeout minutes.");
//   }

//   void _stopTimer() {
//     _timer?.cancel();
//     _timer = null;
//     print("Stopping idle timer.");
//   }

//   void resetTimer() {
//     if (authProvider.isLoggedIn) {
//       print("User interaction detected, resetting timer.");
//       _startTimer();
//     }
//   }

//   Future<void> _onTimeout() async {
//     print("Idle timeout expired. Logging out.");
//     await authProvider.logout();
//     if (navigatorKey.currentContext != null) {
//       Navigator.of(navigatorKey.currentContext!).pushReplacement(
//         MaterialPageRoute(builder: (_) => LoginScreen()),
//       );
//     }
//   }

//     void logoutAndCloseApp(BuildContext context) async {
//     await authProvider.logout();
//     SystemNavigator.pop();
//   }
// }