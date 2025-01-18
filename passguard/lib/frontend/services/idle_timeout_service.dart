import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passguard/frontend/providers/auth_provider.dart';
import 'package:passguard/frontend/providers/settings_provider.dart';

class IdleTimeoutService with WidgetsBindingObserver {
  final BuildContext context;
  Timer? _inactivityTimer;

  IdleTimeoutService({required this.context});

  void start() {
    // Start observing app lifecycle events
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  void stop() {
    // Remove observer and cancel timer
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
  }

  /// Reset the inactivity timer
  void _resetTimer() {
    _inactivityTimer?.cancel();

    final idleTimeout = context.read<SettingsProvider>().idleTimeout;
    _inactivityTimer = Timer(Duration(minutes: idleTimeout), _onTimeout);
  }

  /// Handle timeout
  Future<void> _onTimeout() async {
    // Perform auto-lock logic
    final authProvider = context.read<AuthProvider>();

    await authProvider.logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  /// Reset timer on user interaction
  void resetOnInteraction() => _resetTimer();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resetTimer(); // Reset timer when app is resumed
    } else if (state == AppLifecycleState.paused) {
      _inactivityTimer?.cancel(); // Stop timer when app is paused
    }
  }
}
