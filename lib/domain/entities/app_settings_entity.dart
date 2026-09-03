/// Domain entity AppSettings — mirror `lib/database/tables/app_settings.dart:3-12`
class AppSettingsEntity {
  final int id;
  final String currency; // IDR
  final bool isDarkMode;
  final String language; // id
  final DateTime? lastBackup;
  final String profileName;
  final String profileEmail;
  final bool budgetWarningEnabled;

  const AppSettingsEntity({
    required this.id,
    required this.currency,
    required this.isDarkMode,
    required this.language,
    this.lastBackup,
    this.profileName = 'Pengguna',
    this.profileEmail = '',
    this.budgetWarningEnabled = true,
  });

  AppSettingsEntity copyWith({
    int? id,
    String? currency,
    bool? isDarkMode,
    String? language,
    DateTime? lastBackup,
    String? profileName,
    String? profileEmail,
    bool? budgetWarningEnabled,
  }) =>
      AppSettingsEntity(
        id: id ?? this.id,
        currency: currency ?? this.currency,
        isDarkMode: isDarkMode ?? this.isDarkMode,
        language: language ?? this.language,
        lastBackup: lastBackup ?? this.lastBackup,
        profileName: profileName ?? this.profileName,
        profileEmail: profileEmail ?? this.profileEmail,
        budgetWarningEnabled: budgetWarningEnabled ?? this.budgetWarningEnabled,
      );
}
