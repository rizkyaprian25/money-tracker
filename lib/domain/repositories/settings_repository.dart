import '../entities/app_settings_entity.dart';

abstract class SettingsRepository {
  Stream<AppSettingsEntity?> watchSettings();
  Future<AppSettingsEntity?> getSettings();
  Future<void> setDarkMode(bool value);
  Future<void> setCurrency(String currency);
  Future<void> updateLastBackup(DateTime now);
}
