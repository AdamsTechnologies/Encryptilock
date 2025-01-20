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
  int? _lastIdleTimeout; // Store the last known idleTimeout value

  IdleTimeoutProvider({required this.navigatorKey});

  /// Starts tracking idle timeout
  void startTracking(BuildContext context) {
    assert(!isTracking, "IdleTimeoutProvider is already tracking!");
    print("Starting idle timeout tracking");

    WidgetsBinding.instance.addObserver(this);
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);

    isTracking = true;
    syncIdleTimeout(); // Initial sync
  }

  /// Stops tracking idle timeout
  void stopTracking() {
    if (!isTracking) return;

    print("Stopping idle timeout tracking");
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();

    isTracking = false;
  }

  /// Resets the inactivity timer
  void _resetTimer() {
    if (!isTracking) return;

    _inactivityTimer?.cancel();
    final idleTimeout = settingsProvider?.idleTimeout ?? 1; // Default to 1 minute
    print("Resetting timer with timeout: $idleTimeout minutes");

    _inactivityTimer = Timer(Duration(minutes: idleTimeout), () {
      print("Timer expired - executing timeout");
      _onTimeout();
    });
  }

  // Syncs the timer with the current idleTimeout value
  void syncIdleTimeout() { // Make this public
    final currentIdleTimeout = settingsProvider?.idleTimeout;
    if (currentIdleTimeout != _lastIdleTimeout) {
      _lastIdleTimeout = currentIdleTimeout;
      print("idleTimeout changed, syncing timer");
      _resetTimer();
    }
  }

  /// Resets the timer on user interaction
  void resetOnInteraction() {
    if (!isTracking) return;
    print("User interaction detected - resetting timer");
    _resetTimer();
  }

  /// Handles the timeout event
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

  /// Handles app lifecycle changes
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

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:passguard/frontend/providers/auth_provider.dart';
// import 'package:passguard/frontend/providers/settings_provider.dart';
// import 'package:passguard/frontend/screens/login_screen.dart';

// class IdleTimeoutProvider with ChangeNotifier, WidgetsBindingObserver {
//   Timer? _inactivityTimer;
//   final GlobalKey<NavigatorState> navigatorKey;
//   SettingsProvider? settingsProvider;
//   AuthProvider? authProvider;
//   bool isTracking = false;

//   IdleTimeoutProvider({required this.navigatorKey});

//   /// Starts tracking idle timeout
//   void startTracking(BuildContext context) {
//     assert(!isTracking, "IdleTimeoutProvider is already tracking!");
//     print("Starting idle timeout tracking");

//     WidgetsBinding.instance.addObserver(this);
//     settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
//     authProvider = Provider.of<AuthProvider>(context, listen: false);

//     isTracking = true;
//     _resetTimer();
//   }

//   /// Stops tracking idle timeout
//   void stopTracking() {
//     if (!isTracking) return;

//     print("Stopping idle timeout tracking");
//     WidgetsBinding.instance.removeObserver(this);
//     _inactivityTimer?.cancel();

//     isTracking = false;
//   }

//   /// Resets the inactivity timer
//   void _resetTimer() {
//     if (!isTracking) return;

//     _inactivityTimer?.cancel();
//     final idleTimeout = settingsProvider?.idleTimeout ?? 1; // Default to 1 minute
//     print("Resetting timer with timeout: $idleTimeout minutes");

//     _inactivityTimer = Timer(Duration(minutes: idleTimeout), () {
//       print("Timer expired - executing timeout");
//       _onTimeout();
//     });
//   }

//   /// Resets the timer on user interaction
//   void resetOnInteraction() {
//     if (!isTracking) return;
//     print("User interaction detected - resetting timer");
//     _resetTimer();
//   }

//   /// Handles the timeout event
//   Future<void> _onTimeout() async {
//     if (!isTracking) return;

//     print("Timeout occurred - logging out");
//     try {
//       await authProvider?.logout();
//       if (navigatorKey.currentState?.mounted ?? false) {
//         navigatorKey.currentState?.pushReplacement(
//           MaterialPageRoute(builder: (_) => LoginScreen()),
//         );
//       }
//     } catch (e) {
//       print("Error during timeout logout: $e");
//     }
//   }

//   /// Handles app lifecycle changes
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     print("App lifecycle state changed to: $state");
//     if (state == AppLifecycleState.resumed) {
//       _resetTimer();
//     } else if (state == AppLifecycleState.paused) {
//       _inactivityTimer?.cancel();
//     }
//   }
// }
