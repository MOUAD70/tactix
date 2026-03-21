import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme() {
    const background = Color(0xFF0F0F0F);
    const surface = Color(0xFF1A1A2E);
    const primary = Color(0xFF00D4AA);
    const accent = Color(0xFFE94560);
    const textPrimary = Color(0xFFFFFFFF);
    const textSecondary = Color(0xFFA0A0B0);

    final colorScheme = ColorScheme.dark(
      surface: surface,
      primary: primary,
      secondary: accent,
      onSurface: textPrimary,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
    );

    return _buildTheme(colorScheme, background, textPrimary, textSecondary);
  }

  static ThemeData lightTheme() {
    const background = Color(0xFFF5F5F7);
    const surface = Colors.white;
    const primary = Color(0xFF00D4AA);
    const accent = Color(0xFFE94560);
    const textPrimary = Color(0xFF1D1D1F);
    const textSecondary = Color(0xFF86868B);

    final colorScheme = ColorScheme.light(
      surface: surface,
      primary: primary,
      secondary: accent,
      onSurface: textPrimary,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    );

    return _buildTheme(colorScheme, background, textPrimary, textSecondary);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, Color background, Color textPrimary, Color textSecondary) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      cardColor: colorScheme.surface,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16, // Reduced title spacing
        toolbarHeight: 56, // Standard height but explicit
        iconTheme: IconThemeData(color: textPrimary, size: 22),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.brightness == Brightness.dark ? const Color(0xFF172033) : Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.brightness == Brightness.dark ? Colors.black : Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: textSecondary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        height: 60, // Reduced height for mobile feel
        indicatorColor: colorScheme.primary.withOpacity(0.15),
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(size: 20), // Smaller icons
        ),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w500, fontSize: 11), // Smaller font
        ),
      ),
    );
  }
}
