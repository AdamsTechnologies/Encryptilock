import 'package:flutter/material.dart';

class ThemeConfig {
  static final List<String> themes = [
    'dark',
    'light',
    'encrypti',
    'lock',
    'darkwild',
    'lightwild',
    'earthen',
  ];

  static double defaultBorderRadius = 4.0; // Default border radius

  static ThemeData getTheme(String themeName, {double? borderRadius}) {
    final adjustedRadius = borderRadius ?? defaultBorderRadius;

    switch (themeName) {
      case 'dark':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(primary: Colors.blue),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(adjustedRadius),
                ),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
            ),
          ),
        );
      case 'lock':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(onSurface: Colors.deepOrange, primary: Colors.red, secondary: Colors.redAccent),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(adjustedRadius),
                ),
              ),
            ),
          ),
        );
      case 'encrypti':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(surface: Color.fromARGB(255, 171, 221, 245) , onSurface: Colors.lightBlue, primary: Colors.deepOrangeAccent, secondary: Colors.brown),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(adjustedRadius),
                ),
              ),
            ),
          ),
        );
      case 'darkwild':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(primary: Colors.yellow, secondary: Colors.deepPurpleAccent),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(adjustedRadius),
                ),
              ),
            ),
          ),
        );
      case 'lightwild':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.deepPurple, secondary: Colors.cyanAccent),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(adjustedRadius),
                ),
              ),
            ),
          ),
        );
      case 'earthen':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            surface: Color.fromRGBO(223, 202, 195, 1),
            onSurface: Colors.brown,
            primary: Color.fromARGB(255, 103, 141, 59),
            secondary: Colors.deepOrange,
            tertiary: Color.fromARGB(255, 182, 155, 74),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(adjustedRadius),
                ),
              ),
            ),
          ),
        );
      case 'light':
      default:
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.blue),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(adjustedRadius),
                ),
              ),
            ),
          ),
        );
    }
  }
}