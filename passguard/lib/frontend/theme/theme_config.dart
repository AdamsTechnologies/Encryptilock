import 'package:flutter/material.dart';

class ThemeConfig {
  static double defaultBorderRadius = 4.0;
  static final List<String> themes = [
    // -- DARK THEMES --
    'Dark', // similar to Cyber Crimson...
    'Lock', // good neutral dark theme
    'Neon Sunset', // good contrast
    'CyberTech', // Good Cyber
    'Jungle Night', // Good different dark theme.
    'Midnight Mint', // Good contrast for Mint
    'Sapphire', // Good
    'Depths', // good
    'Solar Eclipse', // Good!
    'Cyber Crimson', // Good! change the Green to something else though.
    'Dark Bubblegum',
    // -- LIGHT THEMES --
    'Light', // good
    'bubblegum', // good
    'White Mint',
    'Harvest',
    'Amber Glow', // change the blue with something else.
    'blindingPearl', // THis is just bubblegum.. get it replaced.
    'Eleven Bravo', // meh pretty much same as Mint
    'Mint', // good
    'Paper',
  ];

  static ThemeData getTheme(String themeName, {double? borderRadius}) {
    final double adjustedRadius = borderRadius ?? defaultBorderRadius;

    switch (themeName) {
      // ---------------------------------------------------------------------
      // ======================== DARK THEMES ============================
      // ---------------------------------------------------------------------
      case 'Dark':
        return ThemeData.dark(useMaterial3: true);
      case 'Lock':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            surface: Color(0xFF20232A), // Deep steel gray
            onSurface: Color(0xFFEAEAEA),
            primary: Color(0xFF4E5B64), // Slate steel blue
            secondary: Color(0xFF90CAF9),
            tertiary: Color(0xFFE0E0E0),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4E5B64),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
        );

      case 'Neon Sunset':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF0099),
            secondary: Color(0xFF00FFFF),
            surface: Color(0xFF240035),
            // background removed
            tertiary: Color(0xFFFFCC00),
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onSurface: Color(0xFFF8F8FF),
            error: Color(0xFFFF5252),
          ),
          scaffoldBackgroundColor: const Color(0xFF10001A),
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFFF8F8FF)),
            bodyLarge: TextStyle(letterSpacing: 0.5, fontSize: 16, color: Color(0xFFF8F8FF)),
            bodyMedium: TextStyle(color: Color(0xFFF8F8FF)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFFFF0099),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
                side: const BorderSide(color: Color(0xFF00FFFF), width: 2),
              ),
            ),
          ),
          cardTheme: CardTheme(
            color: const Color(0xFF240035),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFF00FFFF), width: 1),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF00FFFF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF00FFFF)),
            ),
            fillColor: const Color(0xFF240035),
            filled: true,
            labelStyle: const TextStyle(color: Color(0xFFFF99CC)),
            hintStyle: const TextStyle(color: Color(0xFFDDAADD)),
          ),
          dropdownMenuTheme: const DropdownMenuThemeData(
            textStyle: TextStyle(color: Color(0xFFF8F8FF)),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xFF240035)),
            ),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF00FFFF),
          ),
        );

      case 'CyberTech':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E5FF),
            secondary: Color(0xFFFFD700),
            surface: Color(0xFF0A1929),
            // background removed
            tertiary: Color(0xFFFF3D00),
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onSurface: Color(0xFFE0F7FA),
            error: Color(0xFFFF5252),
          ),
          scaffoldBackgroundColor: const Color(0xFF051224),
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFFE0F7FA)),
            bodyLarge: TextStyle(letterSpacing: 0.25, fontSize: 16, color: Color(0xFFE0F7FA)),
            bodyMedium: TextStyle(color: Color(0xFFE0F7FA)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Color(0xFF00E5FF),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          cardTheme: CardTheme(
            color: const Color(0xFF0A1929),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFF00E5FF), width: 1),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF00E5FF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF00E5FF)),
            ),
            fillColor: const Color(0xFF0A1929),
            filled: true,
            labelStyle: const TextStyle(color: Color(0xFF80DEEA)),
            hintStyle: const TextStyle(color: Color(0xFF58CDE8)),
          ),
          dropdownMenuTheme: const DropdownMenuThemeData(
            textStyle: TextStyle(color: Color(0xFFE0F7FA)),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xFF0A1929)),
            ),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF00E5FF),
          ),
        );

      case 'Jungle Night':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00C853),
            secondary: Color(0xFFFFC400),
            surface: Color(0xFF1E2B22),
            // background removed
            tertiary: Color(0xFFFF6D00),
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onSurface: Color(0xFFE8F5E9),
            error: Color(0xFFFF5252),
          ),
          scaffoldBackgroundColor: const Color(0xFF0C1710),
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5, color: Color(0xFFE8F5E9)),
            bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFE8F5E9)),
            bodyMedium: TextStyle(color: Color(0xFFE8F5E9)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Color(0xFF00C853),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          cardTheme: CardTheme(
            color: const Color(0xFF1E2B22),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius * 1.25),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
            ),
            fillColor: const Color(0xFF1E2B22),
            filled: true,
            labelStyle: const TextStyle(color: Color(0xFF9EE4A0)),
            hintStyle: const TextStyle(color: Color(0xFF7EC78B)),
          ),
          dropdownMenuTheme: const DropdownMenuThemeData(
            textStyle: TextStyle(color: Color(0xFFE8F5E9)),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xFF1E2B22)),
            ),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF00C853),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1B5E20),
            foregroundColor: Colors.white,
          ),
        );

      case 'Midnight Mint':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: ColorScheme.dark(
            surface: const Color(0xFF1B1D1E),
            onSurface: const Color(0xFFB2DFDB),
            primary: const Color(0xFF009688),
            secondary: const Color(0xFF80CBC4),
            tertiary: const Color(0xFF4DB6AC),
          ),
          scaffoldBackgroundColor: const Color(0xFF102026),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF009688),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
        );

      case 'Sapphire':
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: ColorScheme.dark(
            surface: const Color(0xFF1A1F24),
            onSurface: const Color(0xFF82E9DE),
            primary: const Color(0xFF0AEFFF),
            secondary: const Color(0xFF005F73),
            tertiary: const Color(0xFF0AAAEF),
            // background removed
          ),
          scaffoldBackgroundColor: const Color(0xFF0B0C10),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0AEFFF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
        );
      case 'Depths':
        // Dark with a deep blue/purple oceanic vibe
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4A33A3), // Rich indigo
            secondary: Color(0xFF6D94D6), // Soft ocean blue
            surface: Color(0xFF1A1B2B), // Dark navy
            tertiary: Color(0xFF00BAA4), // Aqua accent
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Color(0xFFDBE2F8), // Light bluish
          ),
          scaffoldBackgroundColor: const Color(0xFF101123),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A33A3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFF1A1B2B),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
            ),
            labelStyle: const TextStyle(color: Color(0xFFDBE2F8)),
          ),
        );
      case 'Solar Eclipse':
        // Dark with black/yellow sun-like contrasts
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFBF00), // Bright solar yellow
            secondary: Color(0xFF363636), // Charcoal
            surface: Color(0xFF1F1F1F),
            tertiary: Color(0xFFFF8C00), // Deep orange accent
            onPrimary: Colors.black,
            onSecondary: Colors.white,
            onSurface: Color(0xFFD9D9D9),
          ),
          scaffoldBackgroundColor: const Color(0xFF0D0D0D),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFBF00),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFFFFBF00)),
        );

      case 'Cyber Crimson':
        // Dark with black, intense red, neon green highlight
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD50000), // Fierce red
            secondary: Color.fromARGB(255, 226, 230, 0), // Neon green
            surface: Color(0xFF1A1A1A),
            tertiary: Color(0xFFFF9100), // Vibrant orange
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onSurface: Color(0xFFE0E0E0),
          ),
          scaffoldBackgroundColor: const Color(0xFF0B0B0B),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD50000),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          cardTheme: CardTheme(
            color: const Color(0xFF1A1A1A),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFF00E676), width: 1),
            ),
          ),
        );
      case 'Dark Bubblegum':
        // Dark, neon pink + acid green
        return ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF00D5), // Hot pink
            secondary: Color(0xFFADFF2F), // Acid green
            surface: Color(0xFF1B0014),
            tertiary: Color(0xFFFFFF00), // Electric yellow
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onSurface: Color(0xFFFFC0EB),
            error: Color(0xFFFF5252),
          ),
          scaffoldBackgroundColor: const Color(0xFF0D000B),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF00D5),
              foregroundColor: Colors.black,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
                side: const BorderSide(color: Color(0xFFADFF2F), width: 2),
              ),
            ),
          ),
        );
      // ---------------------------------------------------------------------
      // ========================= LIGHT THEMES =============================
      // ---------------------------------------------------------------------
      case 'Light':
        return ThemeData.light(useMaterial3: true);

      case 'bubblegum':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            surface: Color(0xFFFDF5FF),
            onSurface: Color(0xFF4E004C),
            primary: Color(0xFFFF3D81),
            secondary: Color(0xFFE1BEE7),
            tertiary: Color(0xFFCDDC39),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF3D81),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
        );

      case 'White Mint':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF00BD9D),
            secondary: Color(0xFFFF8E6E),
            surface: Color(0xFFF8F9FA),
            tertiary: Color(0xFF6247AA),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Color(0xFF2D3047),
            error: Color(0xFFD32F2F),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F7F9),
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D3047)),
            bodyLarge: TextStyle(color: Color(0xFF2D3047), fontSize: 16),
            bodyMedium: TextStyle(color: Color(0xFF2D3047)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFF00BD9D),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          cardTheme: CardTheme(
            color: const Color(0xFFFFFFFF),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius * 1.25),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
            ),
            fillColor: Color(0xFFFFFFFF),
            filled: true,
            labelStyle: const TextStyle(color: Color(0xFF2D3047)),
            hintStyle: const TextStyle(color: Color(0xFF9999AA)),
          ),
          dropdownMenuTheme: const DropdownMenuThemeData(
            textStyle: TextStyle(color: Color(0xFF2D3047)),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.white),
            ),
          ),
        );

      case 'Harvest':
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFE76F51),
            secondary: Color(0xFFF4A261),
            surface: Color(0xFFF9F5EB),
            tertiary: Color(0xFF3A6B35),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Color(0xFF2D2A25),
            error: Color(0xFFC62828),
          ),
          scaffoldBackgroundColor: const Color(0xFFE9E3D6),
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D2A25)),
            bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF2D2A25)),
            bodyMedium: TextStyle(color: Color(0xFF2D2A25)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFFE76F51),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          cardTheme: CardTheme(
            color: Color(0xFFF9F5EB),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius * 1.5),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
            ),
            fillColor: Color(0xFFF9F5EB),
            filled: true,
            labelStyle: TextStyle(color: Color(0xFF2D2A25)),
            hintStyle: TextStyle(color: Color(0xFF7D7A75)),
          ),
          dropdownMenuTheme: const DropdownMenuThemeData(
            textStyle: TextStyle(color: Color(0xFF2D2A25)),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xFFF9F5EB)),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF3A6B35),
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFF4A261),
            foregroundColor: Colors.white,
          ),
        );

      case 'Amber Glow':
        // "Pizzazz" it up: stronger gold/orange, some accent teal
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFFF9100), // Brighter orange
            secondary: Color(0xFF00B8D4), // Vivid teal accent
            surface: Color(0xFFFFF4E1), // Lighter warm cream
            tertiary: Color(0xFF00897B), // Additional teal for highlights
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Color(0xFF3E2723),
            error: Color(0xFFD32F2F),
          ),
          scaffoldBackgroundColor: const Color(0xFFFFFAEE), // Subtly different from surface
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3E2723)),
            bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF3E2723)),
            bodyMedium: TextStyle(color: Color(0xFF3E2723)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFFFF9100),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          cardTheme: CardTheme(
            color: const Color(0xFFFFF4E1),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius * 1.2),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFFFF9100)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFFFF9100)),
            ),
            fillColor: const Color(0xFFFFF4E1),
            filled: true,
            labelStyle: const TextStyle(color: Color(0xFFD84315)),
            hintStyle: const TextStyle(color: Color(0xFFFFAB91)), // Lighter orange
          ),
          dropdownMenuTheme: const DropdownMenuThemeData(
            textStyle: TextStyle(color: Color(0xFF3E2723)),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xFFFFF4E1)),
            ),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFFFF9100),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFF9100),
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF00B8D4),
            foregroundColor: Colors.white,
          ),
        );
      case 'blindingPearl':
        // Very bright white base with subtle pink & baby blue accents
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFE91E63), // Pink
            secondary: Color(0xFF90CAF9), // Light baby blue
            surface: Color(0xFFFFFEFE), // Almost pure white
            tertiary: Color(0xFFF48FB1), // Pink highlight
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onSurface: Color(0xFF333333),
          ),
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFFFFFEFE),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
            ),
          ),
        );

      case 'Eleven Bravo':
        // Crisp sky blue with clouds and sunshine accent
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2196F3), // Sky blue
            secondary: Color(0xFFFFEB3B), // Sunny yellow
            surface: Color(0xFFE0F7FA), // Light aqua
            tertiary: Color(0xFFB3E5FC), // Lighter sky
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onSurface: Color(0xFF29434E), // Muted steel text
          ),
          scaffoldBackgroundColor: const Color(0xFFBBDEFB),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
              ),
            ),
          ),
        );

      case 'Mint':
        // Light mint paper-like theme
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF009688), // Teal
            secondary: Color(0xFF80CBC4), // Light mint
            surface: Color(0xFFE0F2F1),
            tertiary: Color(0xFFA7FFEB),
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onSurface: Color(0xFF004D40),
          ),
          scaffoldBackgroundColor: const Color(0xFFB2DFDB),
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
            fillColor: const Color(0xFFE0F2F1),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
            ),
            labelStyle: const TextStyle(color: Color(0xFF004D40)),
          ),
        );

      // ---------------------------------------------------------------------
      // =================== HIGH-CONTRAST THEMES (2) ========================
      // ---------------------------------------------------------------------
      case 'Paper':
        // Light, pure black & white high contrast
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF000000),
            secondary: Color(0xFFFFFFFF),
            surface: Color(0xFFFDFDFD),
            tertiary: Color(0xFF666666),
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onSurface: Color(0xFF000000),
            error: Color(0xFFD32F2F),
          ),
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000000),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adjustedRadius),
                side: const BorderSide(color: Color(0xFF000000), width: 2),
              ),
            ),
          ),
          cardTheme: CardTheme(
            color: const Color(0xFFFDFDFD),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              side: const BorderSide(color: Color(0xFF000000)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFFFDFDFD),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(adjustedRadius),
              borderSide: const BorderSide(color: Color(0xFF000000)),
            ),
            labelStyle: const TextStyle(color: Color(0xFF000000)),
            hintStyle: const TextStyle(color: Color(0xFF666666)),
          ),
        );
      case "Default":
      default:
        return ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.light(
            surface: Color(0xFFFDFDFD),
            onSurface: Color(0xFF3C3C3C),
            primary: Color(0xFF2196F3),
            secondary: Color(0xFF03A9F4),
            tertiary: Color(0xFFB3E5FC),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
            ),
          ),
        );
    }
  }
}
