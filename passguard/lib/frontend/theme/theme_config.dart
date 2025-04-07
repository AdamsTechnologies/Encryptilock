import 'package:flutter/material.dart';

class ThemeConfig {
  static double defaultBorderRadius = 4.0;

  /// List of 10 themes (5 light and 5 dark themes)
  static final List<String> themes = [
    // ---- LIGHT THEMES ----
    'Light', // default - required
    'Bubblegum',
    'Botanical Breeze',
    'Glacial Blue',
    'Crimson Snow',
    'Deep Blue',
    'Sunlit Meadow',
    'Café Cream',
    'Citrus Circuit',
    'Paper',
    // ---- DARK THEMES ----
    'Dark',
    'Lock',
    'Dark Bubblegum',
    'Crimson Night',
    'Depths',
    'Solar Eclipse',
    'Neon Nightscape',
    'Cyberpunk Noir',
    'Midnight Mint',
    'Starforged Alloy',
  ];

  static ThemeData getTheme(String themeName, {double? borderRadius}) {
    final double adjustedRadius = borderRadius ?? defaultBorderRadius;

    switch (themeName) {
      // ---------------------------------------------------------
      //                   LIGHT THEMES
      // ---------------------------------------------------------
      case 'Light':
        return ThemeData.light(useMaterial3: true);

      case 'Bubblegum':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFFF3D81), // Bubblegum pink
            secondary: Color(0xFFE1BEE7), // Soft lavender
            tertiary: Color(0xFFBA68C8), // Richer purple-pink
            surface: Color(0xFFFFF0FA), // Soft pink-cream
            onPrimary: Colors.white,
            onSecondary: Color(0xFF4E004C),
            onSurface: Color(0xFF4E004C), // Deep plum for contrast
          ),
          scaffoldBackgroundColor: const Color(0xFFFFF6FB), // Barely-tinted pinkish white
          cardTheme: CardTheme(
            color: const Color(0xFFFFF0FA),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFFE1BEE7), width: 1),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3D81),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFFFFF0FA),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFFBA68C8)), // richer tone for fields
            ),
            labelStyle: const TextStyle(color: Color(0xFF880E4F)),
            hintStyle: const TextStyle(color: Color(0xFFB39DDB)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFFFF3D81)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF4E004C)),
            bodyMedium: TextStyle(color: Color(0xFF4E004C)),
            titleLarge: TextStyle(color: Color(0xFF4E004C)),
            titleMedium: TextStyle(color: Color(0xFF4E004C)),
            titleSmall: TextStyle(color: Color(0xFF4E004C)),
            labelLarge: TextStyle(color: Color(0xFF4E004C)),
            labelMedium: TextStyle(color: Color(0xFF4E004C)),
            labelSmall: TextStyle(color: Color(0xFF4E004C)),
            headlineLarge: TextStyle(color: Color(0xFF4E004C)),
            headlineMedium: TextStyle(color: Color(0xFF4E004C)),
            headlineSmall: TextStyle(color: Color(0xFF4E004C)),
          ),
        );
      case 'Botanical Breeze':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF388E3C), // Fresh forest green
            secondary: Color(0xFF81C784), // Sage leaf green
            tertiary: Color(0xFF8D6E63), // Earthy brown (like tree bark)
            surface: Color(0xFFF4FAF3), // Soft green-tinted white
            onPrimary: Colors.white,
            onSecondary: Color(0xFF1B5E20), // Deep green contrast
            onSurface: Color(0xFF2E7D32), // Forest text
          ),
          scaffoldBackgroundColor: const Color(0xFFF1F8E9), // Light moss background
          cardTheme: CardTheme(
            color: const Color(0xFFF4FAF3),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFF8BC34A), width: 1),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF388E3C),
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFFF4FAF3),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4CAF50)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF388E3C), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFF2E7D32)),
            hintStyle: const TextStyle(color: Color(0xFF81C784)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF388E3C)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF2E7D32)),
            bodyMedium: TextStyle(color: Color(0xFF2E7D32)),
            titleLarge: TextStyle(color: Color(0xFF2E7D32)),
            titleMedium: TextStyle(color: Color(0xFF2E7D32)),
            titleSmall: TextStyle(color: Color(0xFF2E7D32)),
            labelLarge: TextStyle(color: Color(0xFF388E3C)),
            labelMedium: TextStyle(color: Color(0xFF388E3C)),
            labelSmall: TextStyle(color: Color(0xFF388E3C)),
            headlineLarge: TextStyle(color: Color(0xFF2E7D32)),
            headlineMedium: TextStyle(color: Color(0xFF2E7D32)),
            headlineSmall: TextStyle(color: Color(0xFF2E7D32)),
          ),
        );
      case 'Glacial Blue':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF00ACC1), // Cool glacier cyan
            secondary: Color(0xFFB3E5FC), // Icy pale blue
            tertiary: Color(0xFF0277BD), // Deep arctic blue
            surface: Color(0xFFF0FCFF), // Almost-white frost
            onPrimary: Colors.white,
            onSecondary: Color(0xFF00323D), // Dark navy-cyan text
            onSurface: Color(0xFF1A1A1A), // Crisp dark gray text
          ),
          scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Ice shelf backdrop
          cardTheme: CardTheme(
            color: const Color(0xFFF0FCFF),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFFB3E5FC), width: 1),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00ACC1),
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFFF0FCFF),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF00ACC1)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00ACC1)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0277BD), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFF0277BD)),
            hintStyle: const TextStyle(color: Color(0xFF81D4FA)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF00ACC1)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF1A1A1A)),
            bodyMedium: TextStyle(color: Color(0xFF1A1A1A)),
            titleLarge: TextStyle(color: Color(0xFF1A1A1A)),
            titleMedium: TextStyle(color: Color(0xFF1A1A1A)),
            titleSmall: TextStyle(color: Color(0xFF1A1A1A)),
            labelLarge: TextStyle(color: Color(0xFF0277BD)),
            labelMedium: TextStyle(color: Color(0xFF0277BD)),
            labelSmall: TextStyle(color: Color(0xFF0277BD)),
            headlineLarge: TextStyle(color: Color(0xFF1A1A1A)),
            headlineMedium: TextStyle(color: Color(0xFF1A1A1A)),
            headlineSmall: TextStyle(color: Color(0xFF1A1A1A)),
          ),
        );
      case 'Crimson Snow':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFB71C1C), // Deep bold red
            secondary: Color(0xFFFFCDD2), // Soft accent pink (still used subtly)
            tertiary: Color(0xFFD32F2F), // Mid-level red tone
            surface: Color(0xFFFFFFFF), // True white
            onPrimary: Colors.white,
            onSecondary: Color(0xFF5D0013), // Deep wine for subtle text
            onSurface: Color(0xFF212121), // High-contrast text
          ),
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          cardTheme: CardTheme(
            color: const Color(0xFFFFFFFF), // Clean white card
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFFD32F2F), width: 1),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFFFFFFFF),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFFB71C1C)),
            ),
            labelStyle: const TextStyle(color: Color(0xFF880E4F)),
            hintStyle: const TextStyle(color: Color(0xFFAD1457)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFFB71C1C)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF212121)),
            bodyMedium: TextStyle(color: Color(0xFF212121)),
            titleLarge: TextStyle(color: Color(0xFF212121)),
            titleMedium: TextStyle(color: Color(0xFF212121)),
            titleSmall: TextStyle(color: Color(0xFF212121)),
            labelLarge: TextStyle(color: Color(0xFF5D0013)),
            labelMedium: TextStyle(color: Color(0xFF5D0013)),
            labelSmall: TextStyle(color: Color(0xFF5D0013)),
            headlineLarge: TextStyle(color: Color(0xFF212121)),
            headlineMedium: TextStyle(color: Color(0xFF212121)),
            headlineSmall: TextStyle(color: Color(0xFF212121)),
          ),
        );
      case 'Deep Blue':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0D47A1), // U.S. navy blue
            secondary: Color(0xFFBBDEFB), // Gentle sky blue
            tertiary: Color(0xFF1976D2), // Crisp medium blue for accents
            surface: Color(0xFFF7FAFF), // Very light blue-tinted white
            onPrimary: Colors.white,
            onSecondary: Color(0xFF0D1B3D), // Deep steel/navy
            onSurface: Color(0xFF1A237E), // Indigo-black for main content
          ),
          scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Stark white
          cardTheme: CardTheme(
            color: const Color(0xFFF7FAFF),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFF90CAF9), width: 1),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFFF7FAFF),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF0D47A1)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0D47A1)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0D47A1), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFF0D47A1)),
            hintStyle: const TextStyle(color: Color(0xFF607D8B)), // Cool blue-gray hint
          ),
          iconTheme: const IconThemeData(color: Color(0xFF0D47A1)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF1A237E)),
            bodyMedium: TextStyle(color: Color(0xFF1A237E)),
            titleLarge: TextStyle(color: Color(0xFF1A237E)),
            titleMedium: TextStyle(color: Color(0xFF1A237E)),
            titleSmall: TextStyle(color: Color(0xFF1A237E)),
            labelLarge: TextStyle(color: Color(0xFF0D47A1)),
            labelMedium: TextStyle(color: Color(0xFF0D47A1)),
            labelSmall: TextStyle(color: Color(0xFF0D47A1)),
            headlineLarge: TextStyle(color: Color(0xFF1A237E)),
            headlineMedium: TextStyle(color: Color(0xFF1A237E)),
            headlineSmall: TextStyle(color: Color(0xFF1A237E)),
          ),
        );
      case 'Sunlit Meadow':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF8BC34A), // Fresh meadow green
            secondary: Color(0xFFFFE082), // Morning amber
            tertiary: Color(0xFFFFC107), // Sunbeam yellow-orange
            surface: Color(0xFFFFFEF5), // Light warm white with sun glow
            onPrimary: Colors.black,
            onSecondary: Color(0xFF5D4037), // Earthy brown for anchor text
            onSurface: Color(0xFF33691E), // Dark green for text
          ),
          scaffoldBackgroundColor: const Color(0xFFF9FBE7), // Soft yellow-green backdrop
          cardTheme: CardTheme(
            color: const Color(0xFFFFFEF5),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFFFFF176), width: 1), // Bright warm border
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8BC34A),
              foregroundColor: Colors.black,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFFFFFEF5),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF8BC34A)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8BC34A)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF558B2F), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFF33691E)),
            hintStyle: const TextStyle(color: Color(0xFFAED581)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF8BC34A)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF33691E)),
            bodyMedium: TextStyle(color: Color(0xFF33691E)),
            titleLarge: TextStyle(color: Color(0xFF33691E)),
            titleMedium: TextStyle(color: Color(0xFF33691E)),
            titleSmall: TextStyle(color: Color(0xFF33691E)),
            labelLarge: TextStyle(color: Color(0xFF558B2F)),
            labelMedium: TextStyle(color: Color(0xFF558B2F)),
            labelSmall: TextStyle(color: Color(0xFF558B2F)),
            headlineLarge: TextStyle(color: Color(0xFF33691E)),
            headlineMedium: TextStyle(color: Color(0xFF33691E)),
            headlineSmall: TextStyle(color: Color(0xFF33691E)),
          ),
        );
      case 'Café Cream':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF5D4037), // Deep mocha
            secondary: Color(0xFFD7CCC8), // Warm latte beige
            tertiary: Color(0xFFA1887F), // Subtle cinnamon
            surface: Color(0xFFFFF9F2), // Slightly brighter cream for layering
            onPrimary: Colors.white,
            onSecondary: Color(0xFF3E2723),
            onSurface: Color(0xFF3E2723),
          ),
          scaffoldBackgroundColor: const Color(0xFFFFFBF0),
          cardTheme: CardTheme(
            color: const Color(0xFFFFF9F2),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFFA1887F), width: 1),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D4037),
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFFFFF9F2),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF5D4037)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF5D4037)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF5D4037), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFF5D4037)),
            hintStyle: const TextStyle(color: Color(0xFFA1887F)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF5D4037)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF3E2723)),
            bodyMedium: TextStyle(color: Color(0xFF3E2723)),
            titleLarge: TextStyle(color: Color(0xFF3E2723)),
            titleMedium: TextStyle(color: Color(0xFF3E2723)),
            titleSmall: TextStyle(color: Color(0xFF3E2723)),
            labelLarge: TextStyle(color: Color(0xFF5D4037)),
            labelMedium: TextStyle(color: Color(0xFF5D4037)),
            labelSmall: TextStyle(color: Color(0xFF5D4037)),
            headlineLarge: TextStyle(color: Color(0xFF3E2723)),
            headlineMedium: TextStyle(color: Color(0xFF3E2723)),
            headlineSmall: TextStyle(color: Color(0xFF3E2723)),
          ),
        );
      case 'Citrus Circuit':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF00C853), // Fresh lime
            secondary: Color.fromARGB(255, 247, 252, 178), // Zingy orange
            tertiary: Color(0xFFB2FF59), // Lighter lime accent
            surface: Color(0xFFFFFDF7), // Warm off-white
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onSurface: Color(0xFF263238), // Slate for sharp contrast
          ),
          scaffoldBackgroundColor: const Color(0xFFFFFAF2), // Clean citrus cream
          shadowColor: const Color(0xFF00C85330), // Subtle lime shadow
          cardTheme: CardTheme(
            color: const Color(0xFFFFFDF7),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFF00C853), width: 1.2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
                side: const BorderSide(color: Color(0xFFFFAB00), width: 1),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFFFFFDF7),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF00C853)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00C853)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFFAB00), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFF263238)),
            hintStyle: const TextStyle(color: Color(0xFF789262)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF00C853)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF263238)),
            bodyMedium: TextStyle(color: Color(0xFF263238)),
            titleLarge: TextStyle(color: Color(0xFF263238)),
            titleMedium: TextStyle(color: Color(0xFF263238)),
            titleSmall: TextStyle(color: Color(0xFF263238)),
            labelLarge: TextStyle(color: Color(0xFF00C853)),
            labelMedium: TextStyle(color: Color(0xFF00C853)),
            labelSmall: TextStyle(color: Color(0xFF00C853)),
            headlineLarge: TextStyle(color: Color(0xFF263238)),
            headlineMedium: TextStyle(color: Color(0xFF263238)),
            headlineSmall: TextStyle(color: Color(0xFF263238)),
          ),
        );
      case 'Paper':
        // Light, pure black & white high contrast
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF000000), // Jet black
            secondary: Color(0xFFFFFFFF), // Pure white
            surface: Color(0xFFF8F8F8), // Just a touch off-white for surface layering
            tertiary: Color(0xFF666666), // Neutral mid-gray
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onSurface: Color(0xFF000000),
            error: Color(0xFFD32F2F),
          ),
          scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Crisp base
          cardTheme: CardTheme(
            color: const Color(0xFFF8F8F8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFF000000), width: 1),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000000),
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
                side: const BorderSide(color: Color(0xFF000000), width: 2),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFFF8F8F8),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF000000)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF000000)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF000000), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFF000000)),
            hintStyle: const TextStyle(color: Color(0xFF666666)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF000000)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF000000)),
            bodyMedium: TextStyle(color: Color(0xFF000000)),
            titleLarge: TextStyle(color: Color(0xFF000000)),
            titleMedium: TextStyle(color: Color(0xFF000000)),
            titleSmall: TextStyle(color: Color(0xFF000000)),
            labelLarge: TextStyle(color: Color(0xFF000000)),
            labelMedium: TextStyle(color: Color(0xFF000000)),
            labelSmall: TextStyle(color: Color(0xFF000000)),
            headlineLarge: TextStyle(color: Color(0xFF000000)),
            headlineMedium: TextStyle(color: Color(0xFF000000)),
            headlineSmall: TextStyle(color: Color(0xFF000000)),
          ),
        );
      // ---------------------------------------------------------
      //                   DARK THEMES
      // ---------------------------------------------------------
      case 'Dark':
        return ThemeData.dark(useMaterial3: true);
      case 'Lock':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4E5B64), // Slate steel blue
            secondary: Color(0xFF90CAF9), // Ice-glow blue
            tertiary: Color(0xFFB0BEC5), // Cool gray (brushed aluminum)
            surface: Color(0xFF262A32), // Darker steel gray for layering
            onPrimary: Colors.white,
            onSecondary: Color(0xFFEAEAEA),
            onSurface: Color(0xFFEAEAEA),
          ),
          scaffoldBackgroundColor: const Color(0xFF1A1D23), // Deep steel/navy shell
          cardTheme: CardTheme(
            color: const Color(0xFF262A32),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFF90CAF9), width: 1),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4E5B64),
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFF262A32),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF90CAF9)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF90CAF9)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF90CAF9), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFF90CAF9)),
            hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF90CAF9)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFFEAEAEA)),
            bodyMedium: TextStyle(color: Color(0xFFEAEAEA)),
            titleLarge: TextStyle(color: Color(0xFFEAEAEA)),
            titleMedium: TextStyle(color: Color(0xFFEAEAEA)),
            titleSmall: TextStyle(color: Color(0xFFEAEAEA)),
            labelLarge: TextStyle(color: Color(0xFF90CAF9)),
            labelMedium: TextStyle(color: Color(0xFF90CAF9)),
            labelSmall: TextStyle(color: Color(0xFF90CAF9)),
            headlineLarge: TextStyle(color: Color(0xFFEAEAEA)),
            headlineMedium: TextStyle(color: Color(0xFFEAEAEA)),
            headlineSmall: TextStyle(color: Color(0xFFEAEAEA)),
          ),
        );
      case 'Crimson Night':
        // Dark with black, intense red, neon green highlight
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD50000), // Vivid crimson red
            secondary: Color.fromARGB(255, 66, 1, 1), // Deeper red accent
            tertiary: Color(0xFFFF9100), // Vibrant orange highlight
            surface: Color(0xFF1E1E1E), // Slightly elevated background
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Color(0xFFE0E0E0), // High-contrast soft white
          ),
          scaffoldBackgroundColor: const Color(0xFF0B0B0B),
          cardTheme: CardTheme(
            color: const Color(0xFF1E1E1E),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFFD50000), width: 1),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD50000),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFF1E1E1E),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFFD50000)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD50000)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD50000), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFFD50000)),
            hintStyle: const TextStyle(color: Color(0xFFD50000)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFFD50000)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
            bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
            titleLarge: TextStyle(color: Color(0xFFE0E0E0)),
            titleMedium: TextStyle(color: Color(0xFFE0E0E0)),
            titleSmall: TextStyle(color: Color(0xFFE0E0E0)),
            labelLarge: TextStyle(color: Color(0xFFD50000)),
            labelMedium: TextStyle(color: Color(0xFFD50000)),
            labelSmall: TextStyle(color: Color(0xFFD50000)),
            headlineLarge: TextStyle(color: Color(0xFFE0E0E0)),
            headlineMedium: TextStyle(color: Color(0xFFE0E0E0)),
            headlineSmall: TextStyle(color: Color(0xFFE0E0E0)),
          ),
        );
      case 'Dark Bubblegum':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF00D5), // Hot pink
            secondary: Color(0xFFF11E76), // Electric orchid
            tertiary: Color(0xFFDA70D6), // Soft neon lavender
            surface: Color(0xFF1B0014), // Glossy berry-black
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onSurface: Color(0xFFFFC0EB), // Frosted pink text
            error: Color(0xFFFF5252),
          ),
          scaffoldBackgroundColor: const Color(0xFF090008), // Deeper base
          shadowColor: const Color(0xFFFF00D540), // Neon glow hint
          cardTheme: CardTheme(
            color: const Color(0xFF1F0117), // Slightly brighter than surface for contrast
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFFF11E76), width: 1.5),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF00D5),
              foregroundColor: Colors.black,
              elevation: 5,
              shadowColor: const Color(0xFFFF00D5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
                side: const BorderSide(color: Color(0xFFF11E76), width: 2),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFF1F0117), // Match elevated cards
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFFFF00D5)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFF00D5)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFF11E76), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFFFFC0EB)),
            hintStyle: const TextStyle(color: Color(0xFFEB91D4)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFFFF00D5)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFFFFC0EB)),
            bodyMedium: TextStyle(color: Color(0xFFFFC0EB)),
            titleLarge: TextStyle(color: Color(0xFFFFC0EB)),
            titleMedium: TextStyle(color: Color(0xFFFFC0EB)),
            titleSmall: TextStyle(color: Color(0xFFFFC0EB)),
            labelLarge: TextStyle(color: Color(0xFFF11E76)),
            labelMedium: TextStyle(color: Color(0xFFF11E76)),
            labelSmall: TextStyle(color: Color(0xFFF11E76)),
            headlineLarge: TextStyle(color: Color(0xFFFFC0EB)),
            headlineMedium: TextStyle(color: Color(0xFFFFC0EB)),
            headlineSmall: TextStyle(color: Color(0xFFFFC0EB)),
          ),
        );
      case 'Depths':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4A33A3), // Deep indigo
            secondary: Color(0xFF6D94D6), // Ocean surface blue
            tertiary: Color(0xFF00BAA4), // Aqua glimmer
            surface: Color(0xFF1C1D30), // Brighter than scaffold for float effect
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Color(0xFFDBE2F8), // Frosty seafoam text
          ),
          scaffoldBackgroundColor: const Color(0xFF0E0F20), // Deep trench backdrop
          shadowColor: const Color(0xFF00BAA430), // Subtle teal shimmer shadow
          cardTheme: CardTheme(
            color: const Color(0xFF1C1D30),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFF6D94D6), width: 1.5),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A33A3),
              foregroundColor: Colors.white,
              elevation: 5,
              shadowColor: const Color(0xFF6D94D6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFF1C1D30),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF6D94D6)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D94D6)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00BAA4), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFFDBE2F8)),
            hintStyle: const TextStyle(color: Color(0xFF91A8D0)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF00BAA4)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFFDBE2F8)),
            bodyMedium: TextStyle(color: Color(0xFFDBE2F8)),
            titleLarge: TextStyle(color: Color(0xFFDBE2F8)),
            titleMedium: TextStyle(color: Color(0xFFDBE2F8)),
            titleSmall: TextStyle(color: Color(0xFFDBE2F8)),
            labelLarge: TextStyle(color: Color(0xFF6D94D6)),
            labelMedium: TextStyle(color: Color(0xFF6D94D6)),
            labelSmall: TextStyle(color: Color(0xFF6D94D6)),
            headlineLarge: TextStyle(color: Color(0xFFDBE2F8)),
            headlineMedium: TextStyle(color: Color(0xFFDBE2F8)),
            headlineSmall: TextStyle(color: Color(0xFFDBE2F8)),
          ),
        );
      case 'Solar Eclipse':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFBF00), // Solar yellow
            secondary: Color.fromARGB(255, 63, 35, 1), // Orange flare
            tertiary: Color(0xFFFFD54F), // Warm sun gold
            surface: Color(0xFF1E1C17), // Charred bronze
            onPrimary: Colors.black,
            onSecondary: Colors.white,
            onSurface: Color(0xFFECECEC), // Soft sunlight text
          ),
          scaffoldBackgroundColor: const Color(0xFF0B0B0B), // Total eclipse backdrop
          shadowColor: const Color(0xFFFF8C0030), // Orange glow around cards/buttons
          cardTheme: CardTheme(
            color: const Color(0xFF1E1C17),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFFFFBF00), width: 1.5),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFBF00),
              foregroundColor: Colors.black,
              elevation: 5,
              shadowColor: const Color(0xFFFF8C00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFF1E1C17), // Slight contrast with scaffold
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFFFFBF00)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFFBF00)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFF8C00), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFFFFD54F)),
            hintStyle: const TextStyle(color: Color(0xFFFFE082)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFFFFBF00)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFFECECEC)),
            bodyMedium: TextStyle(color: Color(0xFFECECEC)),
            titleLarge: TextStyle(color: Color(0xFFECECEC)),
            titleMedium: TextStyle(color: Color(0xFFECECEC)),
            titleSmall: TextStyle(color: Color(0xFFECECEC)),
            labelLarge: TextStyle(color: Color(0xFFFFBF00)),
            labelMedium: TextStyle(color: Color(0xFFFFBF00)),
            labelSmall: TextStyle(color: Color(0xFFFFBF00)),
            headlineLarge: TextStyle(color: Color(0xFFECECEC)),
            headlineMedium: TextStyle(color: Color(0xFFECECEC)),
            headlineSmall: TextStyle(color: Color(0xFFECECEC)),
          ),
        );
      case 'Neon Nightscape':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00F0FF), // Electric cyan
            secondary: Color(0xFFDA00F7), // Neon violet/magenta
            tertiary: Color(0xFF9C27B0), // Deep synthetic purple
            surface: Color(0xFF1C1D2D), // Slightly lighter backdrop
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onSurface: Color(0xFFFAFAFA), // Bright UI text
          ),
          scaffoldBackgroundColor: const Color(0xFF0A0B1A), // Deep midnight blue
          shadowColor: const Color(0xFF00F0FF40), // Glowing cyan shadow
          cardTheme: CardTheme(
            color: const Color(0xFF1C1D2D),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFF00F0FF), width: 1.5),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDA00F7), // Neon magenta buttons
              foregroundColor: Colors.white,
              elevation: 5,
              shadowColor: const Color(0xFF00F0FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFF1C1D2D),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF00F0FF)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00F0FF)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFDA00F7), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFFFAFAFA)),
            hintStyle: const TextStyle(color: Color(0xFFB39DDB)), // Soft violet hint
          ),
          iconTheme: const IconThemeData(color: Color(0xFF00F0FF)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFFFAFAFA)),
            bodyMedium: TextStyle(color: Color(0xFFFAFAFA)),
            titleLarge: TextStyle(color: Color(0xFFFAFAFA)),
            titleMedium: TextStyle(color: Color(0xFFFAFAFA)),
            titleSmall: TextStyle(color: Color(0xFFFAFAFA)),
            labelLarge: TextStyle(color: Color(0xFFDA00F7)),
            labelMedium: TextStyle(color: Color(0xFFDA00F7)),
            labelSmall: TextStyle(color: Color(0xFFDA00F7)),
            headlineLarge: TextStyle(color: Color(0xFFFAFAFA)),
            headlineMedium: TextStyle(color: Color(0xFFFAFAFA)),
            headlineSmall: TextStyle(color: Color(0xFFFAFAFA)),
          ),
        );
      case 'Cyberpunk Noir':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00FFD1), // Clean neon cyan
            secondary: Color(0xFF263238), // Gunmetal gray
            tertiary: Color(0xFF1DE9B6), // Aqua mint
            surface: Color(0xFF11181A), // Elevated for panel contrast
            onPrimary: Colors.black,
            onSecondary: Colors.white,
            onSurface: Color(0xFFEFFCF9), // Near-white for crisp readability
          ),
          scaffoldBackgroundColor: const Color(0xFF020708), // Deep noir backdrop
          shadowColor: const Color(0xFF00FFD10F), // Extremely subtle edge hinting
          cardTheme: CardTheme(
            color: const Color.fromARGB(255, 22, 31, 34), // Lifted above backdrop for separation
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFF00FFD1), width: 1.2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FFD1),
              foregroundColor: Colors.black,
              elevation: 0, // No underlight — remains stealth
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
                side: const BorderSide(color: Color(0xFF1DE9B6), width: 1),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFF11181A), // Match card color
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF00FFD1)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00FFD1)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1DE9B6), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFFEFFCF9)),
            hintStyle: const TextStyle(color: Color(0xFF80CBC4)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF00FFD1)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFFEFFCF9)),
            bodyMedium: TextStyle(color: Color(0xFFEFFCF9)),
            titleLarge: TextStyle(color: Color(0xFFEFFCF9)),
            titleMedium: TextStyle(color: Color(0xFFEFFCF9)),
            titleSmall: TextStyle(color: Color(0xFFEFFCF9)),
            labelLarge: TextStyle(color: Color(0xFF00FFD1)),
            labelMedium: TextStyle(color: Color(0xFF00FFD1)),
            labelSmall: TextStyle(color: Color(0xFF00FFD1)),
            headlineLarge: TextStyle(color: Color(0xFFEFFCF9)),
            headlineMedium: TextStyle(color: Color(0xFFEFFCF9)),
            headlineSmall: TextStyle(color: Color(0xFFEFFCF9)),
          ),
        );
      case 'Midnight Mint':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            surface: Color(0xFF2A2D2E), // Lighter than before (was 0xFF1B1D1E)
            onSurface: Color(0xFFB2DFDB), // Mint green for legibility
            primary: Color(0xFF009688), // Teal (mint base)
            secondary: Color(0xFF80CBC4),
            tertiary: Color(0xFF4DB6AC),
          ),
          scaffoldBackgroundColor: const Color(0xFF182428), // Brightened background (was 0xFF102026)
          cardTheme: CardTheme(
            color: const Color(0xFF2A2D2E),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFF4DB6AC), width: 1), // Visible teal border
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF009688),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFF2A2D2E),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF80CBC4)),
            ),
            labelStyle: const TextStyle(color: Color(0xFF80CBC4)),
            hintStyle: const TextStyle(color: Color(0xFF4DB6AC)),
          ),
        );
      case 'Starforged Alloy':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF6F00), // Molten copper
            secondary: Color(0xFF546E7A), // Bluish steel
            tertiary: Color(0xFFB0BEC5), // Cool gray
            surface: Color(0xFF1C1C1C), // Smelted steel dark
            onPrimary: Colors.black,
            onSecondary: Colors.white,
            onSurface: Color(0xFFF0F0F0), // Ceramic pale white
          ),
          scaffoldBackgroundColor: const Color(0xFF121212), // Void baseplate
          shadowColor: const Color(0xFFFF6F0022), // Subtle molten flicker
          cardTheme: CardTheme(
            color: const Color(0xFF1C1C1C),
            elevation: 7,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFFFF6F00), width: 1.2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6F00),
              foregroundColor: Colors.black,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
                side: const BorderSide(color: Color(0xFFB0BEC5), width: 1),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFF1C1C1C),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFFFF6F00)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFF6F00)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFB8C00), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFFF0F0F0)),
            hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFFFF6F00)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFFF0F0F0)),
            bodyMedium: TextStyle(color: Color(0xFFF0F0F0)),
            titleLarge: TextStyle(color: Color(0xFFF0F0F0)),
            titleMedium: TextStyle(color: Color(0xFFF0F0F0)),
            titleSmall: TextStyle(color: Color(0xFFF0F0F0)),
            labelLarge: TextStyle(color: Color(0xFFFF6F00)),
            labelMedium: TextStyle(color: Color(0xFFFF6F00)),
            labelSmall: TextStyle(color: Color(0xFFFF6F00)),
            headlineLarge: TextStyle(color: Color(0xFFF0F0F0)),
            headlineMedium: TextStyle(color: Color(0xFFF0F0F0)),
            headlineSmall: TextStyle(color: Color(0xFFF0F0F0)),
          ),
        );
      // Fallback
      default:
        return ThemeData.light(useMaterial3: true);
    }
  }
}
