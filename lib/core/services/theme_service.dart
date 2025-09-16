import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/app_shared_preferences.dart';

class ThemeService {
  ThemeService();

  ThemeMode getThemeMode() {
    switch (AppPreferences().getData(AppConstants.themeKey)) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final modeStr =
        {
          ThemeMode.dark: 'dark',
          ThemeMode.light: 'light',
          ThemeMode.system: 'system',
        }[mode]!;
    await AppPreferences().setData(AppConstants.themeKey, modeStr);
  }
}
