import 'package:flutter/material.dart';

class AppColors {
  // Primary colors that can be dynamically changed
  static Color primaryColor = const Color(0xFF87CEEB); // Sky Blue (pastel)
  static Color primaryColorDark = const Color(0xFF4682B4); // Steel Blue
  static Color primaryColorLight = const Color(0xFFB0E0E6); // Powder Blue

  // Secondary colors
  static Color secondaryColor = const Color(0xFFFF6B6B); // Coral
  static Color secondaryColorDark = const Color(0xFFE74C3C); // Red
  static Color secondaryColorLight = const Color(0xFFFFB3B3); // Light Pink

  // Accent colors
  static Color accentColor = const Color(0xFFFFA500); // Orange
  static Color accentColorDark = const Color(0xFFFF8C00); // Dark Orange
  static Color accentColorLight = const Color(0xFFFFD700); // Gold

  // Background colors
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Color(0xFFF8F9FA);
  static const Color scaffoldBackgroundColor = Color(0xFFFAFAFA);

  // Text colors
  static const Color textPrimaryColor = Color(0xFF212529);
  static const Color textSecondaryColor = Color(0xFF6C757D);
  static const Color textDisabledColor = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;

  // Border and divider colors
  static const Color dividerColor = Color(0xFFE9ECEF);
  static const Color borderColor = Color(0xFFDEE2E6);
  static const Color focusedBorderColor = Color(0xFF6C757D);

  // Status colors
  static const Color successColor = Color(0xFF28A745);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFDC3545);
  static const Color infoColor = Color(0xFF17A2B8);

  // Shadow and overlay colors
  static const Color shadowColor = Color(0x1A000000);
  static const Color overlayColor = Color(0x40000000);

  // Available theme colors for user selection
  static const List<Color> availableThemeColors = [
    Color(0xFF87CEEB), // Sky Blue (default)
    Color(0xFFFF6B6B), // Coral
    Color(0xFF4ECDC4), // Turquoise
    Color(0xFF45B7D1), // Blue
    Color(0xFF96CEB4), // Sage Green
    Color(0xFFFFA726), // Orange
    Color(0xFFAB47BC), // Purple
    Color(0xFFEF5350), // Red
    Color(0xFF42A5F5), // Light Blue
    Color(0xFF66BB6A), // Green
  ];

  // Theme color names for UI display
  static final Map<Color, String> themeColorNames = {
    const Color(0xFF87CEEB): 'Sky Blue',
    const Color(0xFFFF6B6B): 'Coral',
    const Color(0xFF4ECDC4): 'Turquoise',
    const Color(0xFF45B7D1): 'Blue',
    const Color(0xFF96CEB4): 'Sage Green',
    const Color(0xFFFFA726): 'Orange',
    const Color(0xFFAB47BC): 'Purple',
    const Color(0xFFEF5350): 'Red',
    const Color(0xFF42A5F5): 'Light Blue',
    const Color(0xFF66BB6A): 'Green',
  };

  // Method to update theme colors
  static void updateThemeColors(Color newPrimaryColor) {
    primaryColor = newPrimaryColor;
    primaryColorDark = _darkenColor(newPrimaryColor, 0.2);
    primaryColorLight = _lightenColor(newPrimaryColor, 0.2);

    // Update secondary colors based on primary color
    secondaryColor = _generateSecondaryColor(newPrimaryColor);
    secondaryColorDark = _darkenColor(secondaryColor, 0.2);
    secondaryColorLight = _lightenColor(secondaryColor, 0.2);

    // Update accent colors
    accentColor = _generateAccentColor(newPrimaryColor);
    accentColorDark = _darkenColor(accentColor, 0.2);
    accentColorLight = _lightenColor(accentColor, 0.2);
  }

  // Helper methods to generate complementary colors
  static Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  static Color _generateSecondaryColor(Color primaryColor) {
    final hsl = HSLColor.fromColor(primaryColor);
    final secondaryHsl = hsl.withHue((hsl.hue + 180) % 360);
    return secondaryHsl.toColor();
  }

  static Color _generateAccentColor(Color primaryColor) {
    final hsl = HSLColor.fromColor(primaryColor);
    final accentHsl = hsl.withHue((hsl.hue + 120) % 360);
    return accentHsl.toColor();
  }
}
