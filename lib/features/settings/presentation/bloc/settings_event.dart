part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

final class SettingsFetched extends SettingsEvent {
  const SettingsFetched();
}

final class SettingsLanguageChanged extends SettingsEvent {
  final Language language;
  const SettingsLanguageChanged(this.language);

  @override
  List<Object> get props => [language];
}

final class SettingsThemeChanged extends SettingsEvent {
  final ThemeMode themeMode;
  const SettingsThemeChanged(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

final class SettingsNotificationChanged extends SettingsEvent {
  final bool enabled;
  const SettingsNotificationChanged(this.enabled);

  @override
  List<Object> get props => [enabled];
}

final class SettingsSoundChanged extends SettingsEvent {
  final bool enabled;
  const SettingsSoundChanged(this.enabled);

  @override
  List<Object> get props => [enabled];
}

final class SettingsVibrationChanged extends SettingsEvent {
  final bool enabled;
  const SettingsVibrationChanged(this.enabled);

  @override
  List<Object> get props => [enabled];
}
