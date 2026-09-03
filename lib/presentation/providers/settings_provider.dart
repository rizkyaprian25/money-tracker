import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/app_database.dart';
import 'database_provider.dart';

final settingsStreamProvider = StreamProvider<AppSetting?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchSettings();
});

final settingsProvider = FutureProvider<AppSetting?>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getSettings();
});

final isDarkModeProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsStreamProvider).valueOrNull;
  return settings?.isDarkMode ?? false;
});

class SettingsNotifier {
  final AppDatabase db;
  SettingsNotifier(this.db);

  Future<void> setDarkMode(bool value) async {
    await db.updateSettings(AppSettingsCompanion(isDarkMode: Value(value)));
  }

  Future<void> setCurrency(String currency) async {
    await db.updateSettings(AppSettingsCompanion(currency: Value(currency)));
  }

  Future<void> updateLastBackup(DateTime now) async {
    await db.updateSettings(AppSettingsCompanion(lastBackup: Value(now)));
  }

  Future<void> updateProfile({required String name, required String email}) async {
    await db.updateSettings(AppSettingsCompanion(profileName: Value(name), profileEmail: Value(email)));
  }

  Future<void> setBudgetWarningEnabled(bool value) async {
    await db.updateSettings(AppSettingsCompanion(budgetWarningEnabled: Value(value)));
  }

  Future<void> setPinHash(String hash) async {
    await db.updateSettings(AppSettingsCompanion(pinHash: Value(hash)));
  }

  Future<void> clearPin() async {
    await db.updateSettings(const AppSettingsCompanion(pinHash: Value('')));
  }
}

final settingsNotifierProvider = Provider<SettingsNotifier>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsNotifier(db);
});
