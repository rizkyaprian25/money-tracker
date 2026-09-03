import '../../database/app_database.dart';

/// Thin wrapper — single place to expose `AppDatabase` to data layer.
/// Menghindari import langsung `AppDatabase` di domain.
class LocalDatabase {
  final AppDatabase db;
  LocalDatabase(this.db);
}
