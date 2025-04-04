import 'package:flutter/material.dart';

class ThemeConfig {
  static double defaultBorderRadius = 4.0;

  /// List of 10 themes (5 light and 5 dark themes)
  static final List<String> themes = [
    // ---- LIGHT THEMES ----
    // TODO WE NEED A FEW LIGHT THEMES THAT REALL WORK WITH OTHER COLORS THAN JUST PASTELS, TRY SOME WHITE AND RED, WHITE AND BLUE, LIGHT LIGHT GREEN/ AMBER AND BROWN
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

// ---------------------------------------------------------------------------------- 3.0

// import 'package:flutter/material.dart';

// class ThemeConfig {
//   static double defaultBorderRadius = 4.0;

//   /// List of 10 themes (5 light and 5 new dark themes)
//   static final List<String> themes = [
//     // ---- LIGHT THEMES ----
//     'Aurora Dawn',
//     'Sunlit Canvas',
//     'Frosted Citrus',
//     'Vintage Paper',
//     'Luminous Sky',

//     // ---- DARK THEMES (New Versions) ----
//     'Nocturnal Mirage',
//     'Urban Dusk',
//     'Celestial Shadow',
//     'Digital Twilight',
//     'Mystic Onyx',
//   ];

//   static ThemeData getTheme(String themeName, {double? borderRadius}) {
//     final double adjustedRadius = borderRadius ?? defaultBorderRadius;

//     switch (themeName) {
//       // ---------------------------------------------------------
//       //                   LIGHT THEMES
//       // ---------------------------------------------------------
//       case 'Aurora Dawn':
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFF81D4FA),
//             secondary: Color(0xFFFFAB91),
//             surface: Color(0xFFFFFFFF),
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFF424242),
//           ),
//           scaffoldBackgroundColor: const Color(0xFFFFFFFF),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF81D4FA),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );
//       case 'Sunlit Canvas':
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFFFFF176),
//             secondary: Color(0xFF90A4AE),
//             surface: Color(0xFFFFFFFF),
//             onPrimary: Colors.black,
//             onSecondary: Colors.white,
//             onSurface: Color(0xFF424242),
//           ),
//           scaffoldBackgroundColor: const Color(0xFFFFFFFF),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFFFF176),
//               foregroundColor: Colors.black,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );
//       case 'Frosted Citrus':
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFFFFA726),
//             secondary: Color(0xFFFFD54F),
//             surface: Color(0xFFFFF8E1),
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFF424242),
//           ),
//           scaffoldBackgroundColor: const Color(0xFFFFF8E1),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFFFA726),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );
//       case 'Vintage Paper':
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFFD7CCC8),
//             secondary: Color(0xFFBCAAA4),
//             surface: Color(0xFFFFFDE7),
//             onPrimary: Colors.black,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFF5D4037),
//           ),
//           scaffoldBackgroundColor: const Color(0xFFFFFDE7),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFD7CCC8),
//               foregroundColor: Colors.black,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );
//       case 'Luminous Sky':
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFF4FC3F7),
//             secondary: Color(0xFFB3E5FC),
//             surface: Color(0xFFE1F5FE),
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFF424242),
//           ),
//           scaffoldBackgroundColor: const Color(0xFFE1F5FE),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF4FC3F7),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );

//       // ---------------------------------------------------------
//       //                   NEW DARK THEMES
//       // ---------------------------------------------------------
//       case 'Nocturnal Mirage':
//         return ThemeData.dark(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.dark(
//             primary: Color(0xFF37474F), // deep blue–gray
//             secondary: Color(0xFFFFAB40), // warm amber accent
//             surface: Color(0xFF212121),
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFFE0E0E0),
//           ),
//           scaffoldBackgroundColor: const Color(0xFF121212),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF37474F),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );
//       case 'Urban Dusk':
//         return ThemeData.dark(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.dark(
//             primary: Color(0xFF263238), // dark blue–gray
//             secondary: Color(0xFF00E676), // neon green accent
//             surface: Color(0xFF121212),
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFFE0E0E0),
//           ),
//           scaffoldBackgroundColor: const Color(0xFF121212),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF263238),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );
//       case 'Celestial Shadow':
//         return ThemeData.dark(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.dark(
//             primary: Color(0xFF1A237E), // deep indigo
//             secondary: Color(0xFF90CAF9), // starlight blue
//             surface: Color(0xFF0D0D0D),
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFFE0E0E0),
//           ),
//           scaffoldBackgroundColor: const Color(0xFF0D0D0D),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF1A237E),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );
//       case 'Digital Twilight':
//         return ThemeData.dark(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.dark(
//             primary: Color(0xFF424242), // charcoal
//             secondary: Color(0xFF64B5F6), // cool blue
//             surface: Color(0xFF212121),
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFFE0E0E0),
//           ),
//           scaffoldBackgroundColor: const Color(0xFF212121),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF424242),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );
//       case 'Mystic Onyx':
//         return ThemeData.dark(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.dark(
//             primary: Color(0xFF000000), // pure onyx
//             secondary: Color(0xFFD81B60), // rich magenta accent
//             surface: Color(0xFF121212),
//             onPrimary: Colors.white,
//             onSecondary: Colors.white,
//             onSurface: Color(0xFFE0E0E0),
//           ),
//           scaffoldBackgroundColor: const Color(0xFF121212),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF000000),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );
//       // ---------------------------------------------------------
//       //   Fallback
//       // ---------------------------------------------------------
//       default:
//         return ThemeData.light(useMaterial3: true);
//     }
//   }
// }

// -------------------------------------------------------------------------------------------------- 2.0

// import 'package:flutter/material.dart';

// class ThemeConfig {
//   static double defaultBorderRadius = 4.0;

//   /// New final list of 10 themes
//   static final List<String> themes = [
//     // ---- LIGHT THEMES ----
//     'Modern Minimal',
//     'Sepia Garden',
//     'Citrus Bloom',
//     'Marble Tech',
//     'Sunny Pastel',

//     // ---- DARK THEMES ----
//     'StarForge',
//     'Rustic Noir',
//     'Toxic Jungle',
//     'Mystic Neon',
//     'Galactic Orchid',
//   ];

//   static ThemeData getTheme(String themeName, {double? borderRadius}) {
//     final double adjustedRadius = borderRadius ?? defaultBorderRadius;

//     switch (themeName) {
//       // ---------------------------------------------------------
//       //                    LIGHT THEMES
//       // ---------------------------------------------------------
//       case 'Modern Minimal':
//         // Clean whites, grayscale, subtle teal accent
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFF00897B), // teal accent
//             secondary: Color(0xFF424242),
//             surface: Color(0xFFFDFDFD),
//             onPrimary: Colors.white,
//             onSecondary: Colors.white,
//             onSurface: Color(0xFF333333),
//           ),
//           scaffoldBackgroundColor: const Color(0xFFFFFFFF),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF00897B),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//           textTheme: const TextTheme(
//             titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333)),
//             bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF424242)),
//           ),
//         );

//       case 'Sepia Garden':
//         // Vintage paper + soft green/brown
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFF704214), // deep sepia/brown
//             secondary: Color(0xFFB8AA92), // muted taupe
//             surface: Color(0xFFF7F2ED), // warm vintage paper
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFF5D5348),
//           ),
//           scaffoldBackgroundColor: const Color(0xFFFAF7F2),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF704214),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );

//       case 'Citrus Bloom':
//         // Vibrant oranges & yellows, fresh/energetic
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFFF57C00), // vibrant orange
//             secondary: Color(0xFFFFEB3B), // lemony yellow
//             surface: Color(0xFFFFF7E0), // soft warm off-white
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFF4E342E),
//           ),
//           scaffoldBackgroundColor: const Color(0xFFFFFCE6),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFF57C00),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );

//       case 'Marble Tech':
//         // White/gray marble base, metallic silver, bright aqua accent
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFFA0A0A0), // metallic silver
//             secondary: Color(0xFF18FFFF), // bright aqua accent
//             surface: Color(0xFFFDFDFD),
//             onPrimary: Colors.black,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFF2C2C2C),
//           ),
//           scaffoldBackgroundColor: const Color(0xFFFFFFFF),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFA0A0A0),
//               foregroundColor: Colors.black,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );

//       case 'Sunny Pastel':
//         // Soft pastel peach/pink/blue vibe
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFFFFB5E8), // pastel pink
//             secondary: Color(0xFFB5D0FF), // pastel blue
//             surface: Color(0xFFFEE7CE), // pastel peach
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFF333333),
//           ),
//           scaffoldBackgroundColor: const Color(0xFFFFF9F6),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFFFB5E8),
//               foregroundColor: Colors.black,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );

//       // ---------------------------------------------------------
//       //                    DARK THEMES
//       // ---------------------------------------------------------
//       case 'StarForge':
//         // Black/graphite + fiery orange
//         return ThemeData.dark(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.dark(
//             primary: Color(0xFFFF5722), // fiery orange
//             secondary: Color(0xFF666666),
//             surface: Color(0xFF121212),
//             onPrimary: Colors.white,
//             onSecondary: Colors.white,
//             onSurface: Color(0xFFEEEEEE),
//           ),
//           scaffoldBackgroundColor: const Color(0xFF101010),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFFF5722),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );

//       case 'Rustic Noir':
//         // Dark, moody charcoal + warm rust accent
//         return ThemeData.dark(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.dark(
//             primary: Color(0xFF8D6E63), // warm rust/brown
//             secondary: Color(0xFF424242),
//             surface: Color(0xFF1E1E1E),
//             onPrimary: Colors.white,
//             onSecondary: Colors.white,
//             onSurface: Color(0xFFDCDCDC),
//           ),
//           scaffoldBackgroundColor: const Color(0xFF121212),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF8D6E63),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );

//       case 'Toxic Jungle':
//         // Deep jungle greens + neon lime
//         return ThemeData.dark(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.dark(
//             primary: Color(0xFF1B5E20), // deep jungle green
//             secondary: Color(0xFF00E676), // toxic neon
//             surface: Color(0xFF0F2F13),
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFFD7FFD7),
//           ),
//           scaffoldBackgroundColor: const Color(0xFF0A1F0B),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF00E676),
//               foregroundColor: Colors.black,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );

//       case 'Mystic Neon':
//         // Near-black with neon magenta & cyan
//         return ThemeData.dark(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.dark(
//             primary: Color(0xFFFF00FF), // neon magenta
//             secondary: Color(0xFF00FFFF), // neon cyan
//             surface: Color(0xFF1A0030), // deep purple
//             onPrimary: Colors.black,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFFE0B3FF), // faint purple text
//           ),
//           scaffoldBackgroundColor: const Color(0xFF0F001A),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFFF00FF),
//               foregroundColor: Colors.black,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );

//       case 'Galactic Orchid':
//         // Dark cosmic purples & midnight blues, subtle teal accent
//         return ThemeData.dark(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.dark(
//             primary: Color(0xFF6A1B9A), // deep orchid purple
//             secondary: Color(0xFF80DEEA), // pale teal
//             surface: Color(0xFF1B0036), // very dark purple
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFFD1C4E9), // lavender text
//           ),
//           scaffoldBackgroundColor: const Color(0xFF130026),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF6A1B9A),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );

//       // ---------------------------------------------------------
//       //   Default fallback (if theme not in the list)
//       // ---------------------------------------------------------
//       default:
//         return ThemeData.light(useMaterial3: true);
//     }
//   }
// }

//  ------------------------------------------------------------------------------------------------------ ORIGINAL

// import 'package:flutter/material.dart';

// class ThemeConfig {
//   static double defaultBorderRadius = 4.0;
//   static final List<String> themes = [
//     // -- DARK THEMES --
//     'Dark', // similar to Cyber Crimson...
//     'Lock', // good neutral dark theme
//     'Neon Sunset', // good contrast
//     'CyberTech', // Good Cyber
//     'Jungle Night', // Good different dark theme.
//     'Midnight Mint', // Good contrast for Mint
//     'Sapphire', // Good
//     'Depths', // good
//     'Solar Eclipse', // Good!
//     'Cyber Crimson', // Good! change the Green to something else though.
//     'Dark Bubblegum',
//     // -- LIGHT THEMES --
//     'Light', // good
//     'bubblegum', // good
//     'White Mint',
//     'Harvest',
//     'Amber Glow', // change the blue with something else.
//     'blindingPearl', // THis is just bubblegum.. get it replaced.
//     'Eleven Bravo', // meh pretty much same as Mint
//     'Mint', // good
//     'Paper',
//   ];

//   static ThemeData getTheme(String themeName, {double? borderRadius}) {
//     final double adjustedRadius = borderRadius ?? defaultBorderRadius;

//     switch (themeName) {
//       // ---------------------------------------------------------------------
//       // ======================== DARK THEMES ============================
//       // ---------------------------------------------------------------------
      // case 'Dark':
      //   return ThemeData.dark(useMaterial3: true);
      // case 'Lock':
      //   return ThemeData.dark(useMaterial3: true).copyWith(
      //     colorScheme: const ColorScheme.dark(
      //       surface: Color(0xFF20232A), // Deep steel gray
      //       onSurface: Color(0xFFEAEAEA),
      //       primary: Color(0xFF4E5B64), // Slate steel blue
      //       secondary: Color(0xFF90CAF9),
      //       tertiary: Color(0xFFE0E0E0),
      //     ),
      //     elevatedButtonTheme: ElevatedButtonThemeData(
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: Color(0xFF4E5B64),
      //         foregroundColor: Colors.white,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(adjustedRadius),
      //         ),
      //       ),
      //     ),
      //   );

//       case 'Neon Sunset':
//         return ThemeData.dark(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.dark(
//             primary: Color(0xFFFF0099),
//             secondary: Color(0xFF00FFFF),
//             surface: Color(0xFF240035),
//             // background removed
//             tertiary: Color(0xFFFFCC00),
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFFF8F8FF),
//             error: Color(0xFFFF5252),
//           ),
//           scaffoldBackgroundColor: const Color(0xFF10001A),
//           textTheme: const TextTheme(
//             titleLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFFF8F8FF)),
//             bodyLarge: TextStyle(letterSpacing: 0.5, fontSize: 16, color: Color(0xFFF8F8FF)),
//             bodyMedium: TextStyle(color: Color(0xFFF8F8FF)),
//           ),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: Color(0xFFFF0099),
//               elevation: 5,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//                 side: const BorderSide(color: Color(0xFF00FFFF), width: 2),
//               ),
//             ),
//           ),
//           cardTheme: CardTheme(
//             color: const Color(0xFF240035),
//             elevation: 10,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(adjustedRadius),
//               side: const BorderSide(color: Color(0xFF00FFFF), width: 1),
//             ),
//           ),
//           inputDecorationTheme: InputDecorationTheme(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(adjustedRadius),
//               borderSide: const BorderSide(color: Color(0xFF00FFFF)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(adjustedRadius),
//               borderSide: const BorderSide(color: Color(0xFF00FFFF)),
//             ),
//             fillColor: const Color(0xFF240035),
//             filled: true,
//             labelStyle: const TextStyle(color: Color(0xFFFF99CC)),
//             hintStyle: const TextStyle(color: Color(0xFFDDAADD)),
//           ),
//           dropdownMenuTheme: const DropdownMenuThemeData(
//             textStyle: TextStyle(color: Color(0xFFF8F8FF)),
//             menuStyle: MenuStyle(
//               backgroundColor: WidgetStatePropertyAll(Color(0xFF240035)),
//             ),
//           ),
//           iconTheme: const IconThemeData(
//             color: Color(0xFF00FFFF),
//           ),
//         );

//       case 'CyberTech':
//         return ThemeData.dark(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.dark(
//             primary: Color(0xFF00E5FF),
//             secondary: Color(0xFFFFD700),
//             surface: Color(0xFF0A1929),
//             // background removed
//             tertiary: Color(0xFFFF3D00),
//             onPrimary: Colors.black,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFFE0F7FA),
//             error: Color(0xFFFF5252),
//           ),
//           scaffoldBackgroundColor: const Color(0xFF051224),
//           textTheme: const TextTheme(
//             titleLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFFE0F7FA)),
//             bodyLarge: TextStyle(letterSpacing: 0.25, fontSize: 16, color: Color(0xFFE0F7FA)),
//             bodyMedium: TextStyle(color: Color(0xFFE0F7FA)),
//           ),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.black,
//               backgroundColor: Color(0xFF00E5FF),
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//           cardTheme: CardTheme(
//             color: const Color(0xFF0A1929),
//             elevation: 6,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(adjustedRadius),
//               side: const BorderSide(color: Color(0xFF00E5FF), width: 1),
//             ),
//           ),
//           inputDecorationTheme: InputDecorationTheme(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(adjustedRadius),
//               borderSide: const BorderSide(color: Color(0xFF00E5FF)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(adjustedRadius),
//               borderSide: const BorderSide(color: Color(0xFF00E5FF)),
//             ),
//             fillColor: const Color(0xFF0A1929),
//             filled: true,
//             labelStyle: const TextStyle(color: Color(0xFF80DEEA)),
//             hintStyle: const TextStyle(color: Color(0xFF58CDE8)),
//           ),
//           dropdownMenuTheme: const DropdownMenuThemeData(
//             textStyle: TextStyle(color: Color(0xFFE0F7FA)),
//             menuStyle: MenuStyle(
//               backgroundColor: WidgetStatePropertyAll(Color(0xFF0A1929)),
//             ),
//           ),
//           iconTheme: const IconThemeData(
//             color: Color(0xFF00E5FF),
//           ),
//         );

//       case 'Jungle Night':
//         return ThemeData.dark(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.dark(
//             primary: Color(0xFF00C853),
//             secondary: Color(0xFFFFC400),
//             surface: Color(0xFF1E2B22),
//             // background removed
//             tertiary: Color(0xFFFF6D00),
//             onPrimary: Colors.black,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFFE8F5E9),
//             error: Color(0xFFFF5252),
//           ),
//           scaffoldBackgroundColor: const Color(0xFF0C1710),
//           textTheme: const TextTheme(
//             titleLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5, color: Color(0xFFE8F5E9)),
//             bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFE8F5E9)),
//             bodyMedium: TextStyle(color: Color(0xFFE8F5E9)),
//           ),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.black,
//               backgroundColor: Color(0xFF00C853),
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//           cardTheme: CardTheme(
//             color: const Color(0xFF1E2B22),
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(adjustedRadius * 1.25),
//             ),
//           ),
//           inputDecorationTheme: InputDecorationTheme(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(adjustedRadius),
//             ),
//             fillColor: const Color(0xFF1E2B22),
//             filled: true,
//             labelStyle: const TextStyle(color: Color(0xFF9EE4A0)),
//             hintStyle: const TextStyle(color: Color(0xFF7EC78B)),
//           ),
//           dropdownMenuTheme: const DropdownMenuThemeData(
//             textStyle: TextStyle(color: Color(0xFFE8F5E9)),
//             menuStyle: MenuStyle(
//               backgroundColor: WidgetStatePropertyAll(Color(0xFF1E2B22)),
//             ),
//           ),
//           iconTheme: const IconThemeData(
//             color: Color(0xFF00C853),
//           ),
//           appBarTheme: const AppBarTheme(
//             backgroundColor: Color(0xFF1B5E20),
//             foregroundColor: Colors.white,
//           ),
//         );

      // case 'Midnight Mint':
      //   return ThemeData.dark(useMaterial3: true).copyWith(
      //     colorScheme: ColorScheme.dark(
      //       surface: const Color(0xFF1B1D1E),
      //       onSurface: const Color(0xFFB2DFDB),
      //       primary: const Color(0xFF009688),
      //       secondary: const Color(0xFF80CBC4),
      //       tertiary: const Color(0xFF4DB6AC),
      //     ),
      //     scaffoldBackgroundColor: const Color(0xFF102026),
      //     elevatedButtonTheme: ElevatedButtonThemeData(
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: const Color(0xFF009688),
      //         foregroundColor: Colors.white,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(adjustedRadius),
      //         ),
      //       ),
      //     ),
      //   );

//       case 'Sapphire':
//         return ThemeData.dark(useMaterial3: true).copyWith(
//           colorScheme: ColorScheme.dark(
//             surface: const Color(0xFF1A1F24),
//             onSurface: const Color(0xFF82E9DE),
//             primary: const Color(0xFF0AEFFF),
//             secondary: const Color(0xFF005F73),
//             tertiary: const Color(0xFF0AAAEF),
//             // background removed
//           ),
//           scaffoldBackgroundColor: const Color(0xFF0B0C10),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0AEFFF),
//               foregroundColor: Colors.black,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );
      // case 'Depths':
      //   // Dark with a deep blue/purple oceanic vibe
      //   return ThemeData.dark(useMaterial3: true).copyWith(
      //     colorScheme: const ColorScheme.dark(
      //       primary: Color(0xFF4A33A3), // Rich indigo
      //       secondary: Color(0xFF6D94D6), // Soft ocean blue
      //       surface: Color(0xFF1A1B2B), // Dark navy
      //       tertiary: Color(0xFF00BAA4), // Aqua accent
      //       onPrimary: Colors.white,
      //       onSecondary: Colors.white,
      //       onSurface: Color(0xFFDBE2F8), // Light bluish
      //     ),
      //     scaffoldBackgroundColor: const Color(0xFF101123),
      //     elevatedButtonTheme: ElevatedButtonThemeData(
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: const Color(0xFF4A33A3),
      //         foregroundColor: Colors.white,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(adjustedRadius),
      //         ),
      //       ),
      //     ),
      //     inputDecorationTheme: InputDecorationTheme(
      //       fillColor: const Color(0xFF1A1B2B),
      //       filled: true,
      //       border: OutlineInputBorder(
      //         borderRadius: BorderRadius.circular(adjustedRadius),
      //       ),
      //       labelStyle: const TextStyle(color: Color(0xFFDBE2F8)),
      //     ),
      //   );
      // case 'Solar Eclipse':
      //   // Dark with black/yellow sun-like contrasts
      //   return ThemeData.dark(useMaterial3: true).copyWith(
      //     colorScheme: const ColorScheme.dark(
      //       primary: Color(0xFFFFBF00), // Bright solar yellow
      //       secondary: Color(0xFF363636), // Charcoal
      //       surface: Color(0xFF1F1F1F),
      //       tertiary: Color(0xFFFF8C00), // Deep orange accent
      //       onPrimary: Colors.black,
      //       onSecondary: Colors.white,
      //       onSurface: Color(0xFFD9D9D9),
      //     ),
      //     scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      //     elevatedButtonTheme: ElevatedButtonThemeData(
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: const Color(0xFFFFBF00),
      //         foregroundColor: Colors.black,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(adjustedRadius),
      //         ),
      //       ),
      //     ),
      //     iconTheme: const IconThemeData(color: Color(0xFFFFBF00)),
      //   );

      // case 'Cyber Crimson':
      //   // Dark with black, intense red, neon green highlight
      //   return ThemeData.dark(useMaterial3: true).copyWith(
      //     colorScheme: const ColorScheme.dark(
      //       primary: Color(0xFFD50000), // Fierce red
      //       secondary: Color.fromARGB(255, 226, 230, 0), // Neon green
      //       surface: Color(0xFF1A1A1A),
      //       tertiary: Color(0xFFFF9100), // Vibrant orange
      //       onPrimary: Colors.white,
      //       onSecondary: Colors.black,
      //       onSurface: Color(0xFFE0E0E0),
      //     ),
      //     scaffoldBackgroundColor: const Color(0xFF0B0B0B),
      //     elevatedButtonTheme: ElevatedButtonThemeData(
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: const Color(0xFFD50000),
      //         foregroundColor: Colors.white,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(adjustedRadius),
      //         ),
      //       ),
      //     ),
      //     cardTheme: CardTheme(
      //       color: const Color(0xFF1A1A1A),
      //       elevation: 6,
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(adjustedRadius),
      //         side: const BorderSide(color: Color(0xFF00E676), width: 1),
      //       ),
      //     ),
      //   );
      // case 'Dark Bubblegum':
      //   // Dark, neon pink + acid green
      //   return ThemeData.dark(useMaterial3: true).copyWith(
      //     colorScheme: const ColorScheme.dark(
      //       primary: Color(0xFFFF00D5), // Hot pink
      //       secondary: Color(0xFFADFF2F), // Acid green
      //       surface: Color(0xFF1B0014),
      //       tertiary: Color(0xFFFFFF00), // Electric yellow
      //       onPrimary: Colors.black,
      //       onSecondary: Colors.black,
      //       onSurface: Color(0xFFFFC0EB),
      //       error: Color(0xFFFF5252),
      //     ),
      //     scaffoldBackgroundColor: const Color(0xFF0D000B),
      //     elevatedButtonTheme: ElevatedButtonThemeData(
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: const Color(0xFFFF00D5),
      //         foregroundColor: Colors.black,
      //         elevation: 4,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(adjustedRadius),
      //           side: const BorderSide(color: Color(0xFFADFF2F), width: 2),
      //         ),
      //       ),
      //     ),
      //   );
//       // ---------------------------------------------------------------------
//       // ========================= LIGHT THEMES =============================
//       // ---------------------------------------------------------------------
      // case 'Light':
      //   return ThemeData.light(useMaterial3: true);

      // case 'bubblegum':
      //   return ThemeData.light(useMaterial3: true).copyWith(
      //     colorScheme: const ColorScheme.light(
      //       surface: Color(0xFFFDF5FF),
      //       onSurface: Color(0xFF4E004C),
      //       primary: Color(0xFFFF3D81),
      //       secondary: Color(0xFFE1BEE7),
      //       tertiary: Color(0xFFCDDC39),
      //     ),
      //     elevatedButtonTheme: ElevatedButtonThemeData(
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: Color(0xFFFF3D81),
      //         foregroundColor: Colors.white,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(adjustedRadius),
      //         ),
      //       ),
      //     ),
      //   );

      // case 'White Mint':
      //   return ThemeData.light(useMaterial3: true).copyWith(
      //     colorScheme: const ColorScheme.light(
      //       primary: Color(0xFF00BD9D),
      //       secondary: Color(0xFFFF8E6E),
      //       surface: Color(0xFFF8F9FA),
      //       tertiary: Color(0xFF6247AA),
      //       onPrimary: Colors.white,
      //       onSecondary: Colors.white,
      //       onSurface: Color(0xFF2D3047),
      //       error: Color(0xFFD32F2F),
      //     ),
      //     scaffoldBackgroundColor: const Color(0xFFF5F7F9),
      //     textTheme: const TextTheme(
      //       titleLarge: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D3047)),
      //       bodyLarge: TextStyle(color: Color(0xFF2D3047), fontSize: 16),
      //       bodyMedium: TextStyle(color: Color(0xFF2D3047)),
      //     ),
      //     elevatedButtonTheme: ElevatedButtonThemeData(
      //       style: ElevatedButton.styleFrom(
      //         foregroundColor: Colors.white,
      //         backgroundColor: Color(0xFF00BD9D),
      //         elevation: 2,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(adjustedRadius),
      //         ),
      //       ),
      //     ),
      //     cardTheme: CardTheme(
      //       color: const Color(0xFFFFFFFF),
      //       elevation: 2,
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(adjustedRadius * 1.25),
      //       ),
      //     ),
      //     inputDecorationTheme: InputDecorationTheme(
      //       border: OutlineInputBorder(
      //         borderRadius: BorderRadius.circular(adjustedRadius),
      //       ),
      //       fillColor: Color(0xFFFFFFFF),
      //       filled: true,
      //       labelStyle: const TextStyle(color: Color(0xFF2D3047)),
      //       hintStyle: const TextStyle(color: Color(0xFF9999AA)),
      //     ),
      //     dropdownMenuTheme: const DropdownMenuThemeData(
      //       textStyle: TextStyle(color: Color(0xFF2D3047)),
      //       menuStyle: MenuStyle(
      //         backgroundColor: WidgetStatePropertyAll(Colors.white),
      //       ),
      //     ),
      //   );

//       case 'Harvest':
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFFE76F51),
//             secondary: Color(0xFFF4A261),
//             surface: Color(0xFFF9F5EB),
//             tertiary: Color(0xFF3A6B35),
//             onPrimary: Colors.white,
//             onSecondary: Colors.white,
//             onSurface: Color(0xFF2D2A25),
//             error: Color(0xFFC62828),
//           ),
//           scaffoldBackgroundColor: const Color(0xFFE9E3D6),
//           textTheme: const TextTheme(
//             titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D2A25)),
//             bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF2D2A25)),
//             bodyMedium: TextStyle(color: Color(0xFF2D2A25)),
//           ),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: Color(0xFFE76F51),
//               elevation: 1,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//           cardTheme: CardTheme(
//             color: Color(0xFFF9F5EB),
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(adjustedRadius * 1.5),
//             ),
//           ),
//           inputDecorationTheme: InputDecorationTheme(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(adjustedRadius),
//             ),
//             fillColor: Color(0xFFF9F5EB),
//             filled: true,
//             labelStyle: TextStyle(color: Color(0xFF2D2A25)),
//             hintStyle: TextStyle(color: Color(0xFF7D7A75)),
//           ),
//           dropdownMenuTheme: const DropdownMenuThemeData(
//             textStyle: TextStyle(color: Color(0xFF2D2A25)),
//             menuStyle: MenuStyle(
//               backgroundColor: WidgetStatePropertyAll(Color(0xFFF9F5EB)),
//             ),
//           ),
//           appBarTheme: const AppBarTheme(
//             backgroundColor: Color(0xFF3A6B35),
//             foregroundColor: Colors.white,
//           ),
//           floatingActionButtonTheme: const FloatingActionButtonThemeData(
//             backgroundColor: Color(0xFFF4A261),
//             foregroundColor: Colors.white,
//           ),
//         );

//       case 'Amber Glow':
//         // "Pizzazz" it up: stronger gold/orange, some accent teal
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFFFF9100), // Brighter orange
//             secondary: Color(0xFF00B8D4), // Vivid teal accent
//             surface: Color(0xFFFFF4E1), // Lighter warm cream
//             tertiary: Color(0xFF00897B), // Additional teal for highlights
//             onPrimary: Colors.white,
//             onSecondary: Colors.white,
//             onSurface: Color(0xFF3E2723),
//             error: Color(0xFFD32F2F),
//           ),
//           scaffoldBackgroundColor: const Color(0xFFFFFAEE), // Subtly different from surface
//           textTheme: const TextTheme(
//             titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3E2723)),
//             bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF3E2723)),
//             bodyMedium: TextStyle(color: Color(0xFF3E2723)),
//           ),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: Color(0xFFFF9100),
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//           cardTheme: CardTheme(
//             color: const Color(0xFFFFF4E1),
//             elevation: 3,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(adjustedRadius * 1.2),
//             ),
//           ),
//           inputDecorationTheme: InputDecorationTheme(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(adjustedRadius),
//               borderSide: const BorderSide(color: Color(0xFFFF9100)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(adjustedRadius),
//               borderSide: const BorderSide(color: Color(0xFFFF9100)),
//             ),
//             fillColor: const Color(0xFFFFF4E1),
//             filled: true,
//             labelStyle: const TextStyle(color: Color(0xFFD84315)),
//             hintStyle: const TextStyle(color: Color(0xFFFFAB91)), // Lighter orange
//           ),
//           dropdownMenuTheme: const DropdownMenuThemeData(
//             textStyle: TextStyle(color: Color(0xFF3E2723)),
//             menuStyle: MenuStyle(
//               backgroundColor: WidgetStatePropertyAll(Color(0xFFFFF4E1)),
//             ),
//           ),
//           iconTheme: const IconThemeData(
//             color: Color(0xFFFF9100),
//           ),
//           appBarTheme: const AppBarTheme(
//             backgroundColor: Color(0xFFFF9100),
//             foregroundColor: Colors.white,
//           ),
//           floatingActionButtonTheme: const FloatingActionButtonThemeData(
//             backgroundColor: Color(0xFF00B8D4),
//             foregroundColor: Colors.white,
//           ),
//         );
//       case 'blindingPearl':
//         // Very bright white base with subtle pink & baby blue accents
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFFE91E63), // Pink
//             secondary: Color(0xFF90CAF9), // Light baby blue
//             surface: Color(0xFFFFFEFE), // Almost pure white
//             tertiary: Color(0xFFF48FB1), // Pink highlight
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFF333333),
//           ),
//           scaffoldBackgroundColor: const Color(0xFFFFFFFF),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFE91E63),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//           inputDecorationTheme: InputDecorationTheme(
//             fillColor: const Color(0xFFFFFEFE),
//             filled: true,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(adjustedRadius),
//             ),
//           ),
//         );

//       case 'Eleven Bravo':
//         // Crisp sky blue with clouds and sunshine accent
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFF2196F3), // Sky blue
//             secondary: Color(0xFFFFEB3B), // Sunny yellow
//             surface: Color(0xFFE0F7FA), // Light aqua
//             tertiary: Color(0xFFB3E5FC), // Lighter sky
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFF29434E), // Muted steel text
//           ),
//           scaffoldBackgroundColor: const Color(0xFFBBDEFB),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF2196F3),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//         );

//       case 'Mint':
//         // Light mint paper-like theme
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFF009688), // Teal
//             secondary: Color(0xFF80CBC4), // Light mint
//             surface: Color(0xFFE0F2F1),
//             tertiary: Color(0xFFA7FFEB),
//             onPrimary: Colors.white,
//             onSecondary: Colors.black,
//             onSurface: Color(0xFF004D40),
//           ),
//           scaffoldBackgroundColor: const Color(0xFFB2DFDB),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF009688),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(adjustedRadius),
//               ),
//             ),
//           ),
//           inputDecorationTheme: InputDecorationTheme(
//             fillColor: const Color(0xFFE0F2F1),
//             filled: true,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(adjustedRadius),
//             ),
//             labelStyle: const TextStyle(color: Color(0xFF004D40)),
//           ),
//         );

//       // ---------------------------------------------------------------------
//       // =================== HIGH-CONTRAST THEMES (2) ========================
//       // ---------------------------------------------------------------------
      // case 'Paper':
      //   // Light, pure black & white high contrast
      //   return ThemeData.light(useMaterial3: true).copyWith(
      //     colorScheme: const ColorScheme.light(
      //       primary: Color(0xFF000000),
      //       secondary: Color(0xFFFFFFFF),
      //       surface: Color(0xFFFDFDFD),
      //       tertiary: Color(0xFF666666),
      //       onPrimary: Colors.white,
      //       onSecondary: Colors.black,
      //       onSurface: Color(0xFF000000),
      //       error: Color(0xFFD32F2F),
      //     ),
      //     scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      //     elevatedButtonTheme: ElevatedButtonThemeData(
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: const Color(0xFF000000),
      //         foregroundColor: Colors.white,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(adjustedRadius),
      //           side: const BorderSide(color: Color(0xFF000000), width: 2),
      //         ),
      //       ),
      //     ),
      //     cardTheme: CardTheme(
      //       color: const Color(0xFFFDFDFD),
      //       elevation: 2,
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(adjustedRadius),
      //         side: const BorderSide(color: Color(0xFF000000)),
      //       ),
      //     ),
      //     inputDecorationTheme: InputDecorationTheme(
      //       fillColor: const Color(0xFFFDFDFD),
      //       filled: true,
      //       border: OutlineInputBorder(
      //         borderRadius: BorderRadius.circular(adjustedRadius),
      //         borderSide: const BorderSide(color: Color(0xFF000000)),
      //       ),
      //       labelStyle: const TextStyle(color: Color(0xFF000000)),
      //       hintStyle: const TextStyle(color: Color(0xFF666666)),
      //     ),
      //   );
//       case "Default":
//       default:
//         return ThemeData.light(useMaterial3: true).copyWith(
//           colorScheme: const ColorScheme.light(
//             surface: Color(0xFFFDFDFD),
//             onSurface: Color(0xFF3C3C3C),
//             primary: Color(0xFF2196F3),
//             secondary: Color(0xFF03A9F4),
//             tertiary: Color(0xFFB3E5FC),
//           ),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Color(0xFF2196F3),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(4.0)),
//               ),
//             ),
//           ),
//         );
//     }
//   }
// }
