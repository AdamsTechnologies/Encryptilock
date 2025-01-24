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
    final double adjustedRadius = borderRadius ?? defaultBorderRadius;

    switch (themeName) {
      case 'dark':
        return ThemeData.dark(useMaterial3: true).copyWith(
          // colorScheme: const ColorScheme.dark(primary: Colors.blue),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
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
          colorScheme: const ColorScheme.dark(
            onSurface: Colors.deepOrange,
            primary: Colors.red,
            secondary: Colors.redAccent,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
        );
      case 'encrypti':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            surface: Color.fromARGB(255, 183, 224, 243),
            onSurface: Colors.lightBlue,
            primary: Color.fromARGB(255, 241, 60, 5),
            secondary: Color.fromARGB(255, 240, 109, 62),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
        );
      case 'darkwild':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            surface: Color.fromARGB(255, 24, 4, 27),
            primary: Colors.yellow,
            secondary: Colors.deepPurpleAccent,
          ),
          scaffoldBackgroundColor: Colors.amber,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
        );
      case 'lightwild':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.deepPurple,
            secondary: Colors.cyanAccent,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
        );
      case 'earthen':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            surface: Color.fromRGBO(248, 239, 236, 1),
            onSurface: Colors.brown,
            primary: Color.fromARGB(255, 65, 114, 9),
            secondary: Color.fromARGB(251, 247, 185, 51),
            tertiary: Color.fromARGB(255, 230, 135, 57),
          ),
          scaffoldBackgroundColor: const Color.fromARGB(255, 187, 226, 188),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
        );
      case 'light':
      default:
        return ThemeData.light(useMaterial3: true).copyWith(
          // colorScheme: const ColorScheme.light(primary: Colors.blue),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
        );
    }
  }
}
