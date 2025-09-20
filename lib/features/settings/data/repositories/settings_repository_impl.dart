import 'package:netru_app/core/utils/app_shared_preferences.dart';
import 'package:netru_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:netru_app/features/settings/presentation/domain/settings.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const String _settingsKey = 'app_settings';
  final AppPreferences _preferences;

  const SettingsRepositoryImpl(this._preferences);

  @override
  Future<void> updateSettings(Settings settings) async {
    await _preferences.saveModel<Settings>(
      _settingsKey,
      settings,
      (settings) => settings.toJson(),
    );
  }

  @override
  Future<Settings> getSettings() async {
    final settings = _preferences.getModel<Settings>(
      _settingsKey,
      (json) => Settings.fromJson(json),
    );

    return settings ??
        const Settings(); // Return default settings if none found
  }

  @override
  Future<void> clearSettings() async {
    await _preferences.removeData(_settingsKey);
  }
}
