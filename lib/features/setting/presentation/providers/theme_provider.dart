import 'package:fairsplit/shared/services/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeColorProvider = StateNotifierProvider<ThemeColorNotifier, Color>((
  ref,
) {
  return ThemeColorNotifier();
});

class ThemeColorNotifier extends StateNotifier<Color> {
  ThemeColorNotifier() : super(Colors.yellow) {
    _loadColor();
  }

  void _loadColor() {
    final colorString = SharedPrefsService.getString('theme_color');
    if (colorString == 'pink') {
      state = Colors.pink;
    } else if (colorString == 'blue') {
      state = Colors.blue;
    } else if (colorString == 'yellow') {
      state = Colors.amber;
    }
  }

  void updateColor(Color color) {
    state = color;
    SharedPrefsService.setString('theme_color', _colorToString(color));
  }

  String _colorToString(Color color) {
    if (color.value == const Color.fromARGB(255, 0, 140, 255).value)
      return 'blue';
    if (color.value == const Color.fromARGB(255, 255, 0, 85).value)
      return 'pink';
    return 'yellow';
  }
}
