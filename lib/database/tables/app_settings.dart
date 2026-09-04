import 'package:drift/drift.dart';

class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get currency => text().withDefault(const Constant('IDR'))();
  BoolColumn get isDarkMode => boolean().withDefault(const Constant(false))();
  TextColumn get language => text().withDefault(const Constant('id'))();
  DateTimeColumn get lastBackup => dateTime().nullable()();
  // v3 (fitur sampingan): profil user + toggle peringatan anggaran
  TextColumn get profileName => text().withDefault(const Constant('Pengguna'))();
  TextColumn get profileEmail => text().withDefault(const Constant(''))();
  BoolColumn get budgetWarningEnabled => boolean().withDefault(const Constant(true))();
  // v4 (v1.1): hash SHA-256 PIN kunci layar ('' = tidak dikunci)
  TextColumn get pinHash => text().withDefault(const Constant(''))();
  // v5 (v1.1): sidik jari (default MATI — user menyalakan + pindai sendiri) + jadwal backup
  BoolColumn get biometricEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get autoBackupFreq => text().withDefault(const Constant('weekly'))(); // off | weekly | monthly
  // v6 (pentest 2026-09-04): salt acak per-install untuk hash PIN
  TextColumn get pinSalt => text().withDefault(const Constant(''))();
}
