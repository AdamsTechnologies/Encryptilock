import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';

import 'package:encryptilock/backend/controllers/config_settings_controller.dart';

class DesktopWindowManager {
  static Future<void> initialize(ConfigSettingsController config) async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) return;

    await windowManager.ensureInitialized();
    const double fallbackWidthRatio = 0.4; // 40% screen width
    const double fallbackHeightRatio = 0.6; // 60% screen height

    final widthString = await config.getHashedSetting('window_width');
    final heightString = await config.getHashedSetting('window_height');
    final xString = await config.getHashedSetting('window_x');
    final yString = await config.getHashedSetting('window_y');

    final savedWidth = double.tryParse(widthString ?? '');
    final savedHeight = double.tryParse(heightString ?? '');
    final savedX = double.tryParse(xString ?? '');
    final savedY = double.tryParse(yString ?? '');

    if (savedWidth != null && savedHeight != null && savedWidth > 300 && savedHeight > 300) {
      await windowManager.setSize(Size(savedWidth, savedHeight));
      if (savedX != null && savedY != null) {
        await windowManager.setPosition(Offset(savedX, savedY));
      } else {
        await windowManager.center();
      }
    } else {
      // Fallback: DPI-aware default size
      final display = await screenRetriever.getPrimaryDisplay();
      final width = display.size.width * fallbackWidthRatio;
      final height = display.size.height * fallbackHeightRatio;
      await windowManager.setSize(Size(width, height));
      await windowManager.center();
    }

    await windowManager.setMinimumSize(const Size(400, 300));
    await windowManager.setPreventClose(true);
  }

  static Future<void> saveWindowState(ConfigSettingsController config) async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) return;

    final size = await windowManager.getSize();
    final pos = await windowManager.getPosition();

    await config.setHashedSetting('window_width', (size.width).toString());
    await config.setHashedSetting('window_height', (size.height).toString());
    await config.setHashedSetting('window_x', (pos.dx).toString());
    await config.setHashedSetting('window_y', (pos.dy).toString());
  }
}
