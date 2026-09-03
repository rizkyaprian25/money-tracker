/// Domain entity AppSettings — mirror `lib/database/tables/app_settings.dart:3-9`
class AppSettingsEntity {
  final int id;
  final String currency; // IDR
  final bool isDarkMode;
  final String language; // id
  final DateTime? lastBackup;

  const AppSettingsEntity({
    required this.id,
    required this.currency,
    required this.isDarkMode,
    required this.language,
    this.lastBackup,
  });

  AppSettingsEntity copyWith({
    int? id,
    String? currency,
    bool? isDarkMode,
    String? language,
    DateTime? lastBackup,
  }) =>
      AppSettingsEntity(
        id: id ?? this.id,
        currency: currency ?? this.currency,
        isDarkMode: isDarkMode ?? this.isDarkMode,
        language: language ?? this.language,
        lastBackup: lastBackup ?? this.lastBackup,
      );
}
