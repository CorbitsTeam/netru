import 'package:netru_app/features/settings/presentation/domain/settings.dart';

abstract class SettingsRepository {
  Future<void> updateSettings(Settings settings);
  Future<Settings> getSettings();
  Future<void> clearSettings();
}
