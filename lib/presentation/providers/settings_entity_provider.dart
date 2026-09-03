import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/repository_providers.dart';
import '../../domain/entities/app_settings_entity.dart';

/// Clean-architecture settings provider — uses `SettingsRepository`.

final settingsStreamEntityProvider = StreamProvider<AppSettingsEntity?>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.watchSettings();
});

final settingsEntityProvider = FutureProvider<AppSettingsEntity?>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.getSettings();
});

final isDarkModeEntityProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsStreamEntityProvider).valueOrNull;
  return settings?.isDarkMode ?? false;
});

class SettingsEntityNotifier {
  final dynamic repo; // SettingsRepository
  SettingsEntityNotifier(this.repo);

  Future<void> setDarkMode(bool value) => repo.setDarkMode(value);
  Future<void> setCurrency(String currency) => repo.setCurrency(currency);
  Future<void> updateLastBackup(DateTime now) => repo.updateLastBackup(now);
}

final settingsEntityNotifierProvider = Provider<SettingsEntityNotifier>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsEntityNotifier(repo);
});
