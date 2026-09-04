import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../mappers/entity_mapper.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final AppDatabase db;
  SettingsRepositoryImpl(this.db);

  @override
  Stream<AppSettingsEntity?> watchSettings() => db.watchSettings().map((s) => s?.toEntity());

  @override
  Future<AppSettingsEntity?> getSettings() async {
    final s = await db.getSettings();
    return s?.toEntity();
  }

  @override
  Future<void> setDarkMode(bool value) => db.updateSettings(AppSettingsCompanion(isDarkMode: Value(value)));

  @override
  Future<void> setCurrency(String currency) => db.updateSettings(AppSettingsCompanion(currency: Value(currency)));

  @override
  Future<void> updateLastBackup(DateTime now) => db.updateSettings(AppSettingsCompanion(lastBackup: Value(now)));

  Future<void> updateProfile({required String name, required String email}) =>
      db.updateSettings(AppSettingsCompanion(profileName: Value(name), profileEmail: Value(email)));

  Future<void> setBudgetWarningEnabled(bool value) =>
      db.updateSettings(AppSettingsCompanion(budgetWarningEnabled: Value(value)));

  Future<void> setBiometricEnabled(bool value) =>
      db.updateSettings(AppSettingsCompanion(biometricEnabled: Value(value)));

  Future<void> setAutoBackupFreq(String freq) =>
      db.updateSettings(AppSettingsCompanion(autoBackupFreq: Value(freq)));
}
