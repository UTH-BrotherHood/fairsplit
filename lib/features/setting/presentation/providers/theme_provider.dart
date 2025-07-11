import 'package:fairsplit/shared/services/shared_prefs_service.dart';
import 'package:fairsplit/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeColorProvider = StateNotifierProvider<ThemeColorNotifier, Color>((
  ref,
) {
  return ThemeColorNotifier();
});

class ThemeColorNotifier extends StateNotifier<Color> {
  ThemeColorNotifier() : super(AppColors.availableThemeColors[0]) {
    _loadColor();
  }

  void _loadColor() {
    final colorValue = SharedPrefsService.getInt('theme_color_value');
    if (colorValue != null) {
      final savedColor = Color(colorValue);
      // Check if the saved color is in available colors
      if (AppColors.availableThemeColors.contains(savedColor)) {
        state = savedColor;
        AppColors.updateThemeColors(savedColor);
      }
    }
  }

  void updateColor(Color color) {
    state = color;
    AppColors.updateThemeColors(color);
    SharedPrefsService.setInt('theme_color_value', color.value);
  }
}
