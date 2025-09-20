import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:netru_app/core/cubit/theme/theme_cubit.dart';
import 'package:netru_app/core/cubit/locale/locale_cubit.dart';
import 'package:netru_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:netru_app/features/settings/presentation/domain/settings.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  /// Create a BlocListener widget to sync settings with other cubits
  Widget createSyncListener({required Widget child}) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoaded) {
          syncWithCubits(context, state.settings);
        }
      },
      child: child,
    );
  }

  /// Sync settings with theme and locale cubits when settings change
  void syncWithCubits(BuildContext context, Settings settings) {
    // Update theme cubit
    final themeCubit = context.read<ThemeCubit>();
    if (themeCubit.state.themeMode != settings.themeMode) {
      themeCubit.changeTheme(settings.themeMode);
    }

    // Update locale cubit and EasyLocalization
    final localeCubit = context.read<LocaleCubit>();
    final targetLocale = settings.locale;
    if (localeCubit.state.locale != targetLocale) {
      localeCubit.changeLocale(targetLocale);
      context.setLocale(targetLocale);
    }
  }

  /// Initialize settings from current cubit states
  Settings getInitialSettingsFromCubits(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final localeCubit = context.read<LocaleCubit>();

    final language =
        localeCubit.state.locale.languageCode == 'ar'
            ? Language.arabic
            : Language.english;

    return Settings(language: language, themeMode: themeCubit.state.themeMode);
  }

  /// Update settings and sync with cubits
  void updateLanguage(BuildContext context, Language language) {
    final settingsBloc = context.read<SettingsBloc>();
    settingsBloc.add(SettingsLanguageChanged(language));
  }

  void updateTheme(BuildContext context, ThemeMode themeMode) {
    final settingsBloc = context.read<SettingsBloc>();
    settingsBloc.add(SettingsThemeChanged(themeMode));
  }

  void updateNotifications(BuildContext context, bool enabled) {
    final settingsBloc = context.read<SettingsBloc>();
    settingsBloc.add(SettingsNotificationChanged(enabled));
  }

  void updateSound(BuildContext context, bool enabled) {
    final settingsBloc = context.read<SettingsBloc>();
    settingsBloc.add(SettingsSoundChanged(enabled));
  }

  void updateVibration(BuildContext context, bool enabled) {
    final settingsBloc = context.read<SettingsBloc>();
    settingsBloc.add(SettingsVibrationChanged(enabled));
  }
}
