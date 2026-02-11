import 'dart:async';
import 'package:flutter/material.dart';

class SnackBarProvider with ChangeNotifier {
  String? _currentMessage;
  Timer? _hideTimer;

  String? get currentMessage => _currentMessage;

  void showMessage(String message, {Duration duration = const Duration(seconds: 4)}) {
    _currentMessage = message;
    notifyListeners();

    // Cancel any existing timer and start a new one.
    _hideTimer?.cancel();
    _hideTimer = Timer(duration, () {
      _currentMessage = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }
}
