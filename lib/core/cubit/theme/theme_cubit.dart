import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_constants.dart';
import '../../utils/app_shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(_getInitialTheme()));

  static ThemeMode _getInitialTheme() {
    final savedTheme = AppPreferences().getData(AppConstants.themeKey);
    if (savedTheme == 'dark') {
      return ThemeMode.dark;
    } else if (savedTheme == 'light') {
      return ThemeMode.light;
    } else {
      return ThemeMode.system; // Default theme
    }
  }

  Future<void> changeTheme(ThemeMode newTheme) async {
    await AppPreferences().setData(
      AppConstants.themeKey,
      _themeToString(newTheme),
    );
    emit(ThemeState(newTheme));
  }

  Future<void> toggleTheme() async {
    final newTheme =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await changeTheme(newTheme);
  }

  String _themeToString(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }
}
