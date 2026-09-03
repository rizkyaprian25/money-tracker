import 'package:drift/drift.dart';

class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get currency => text().withDefault(const Constant('IDR'))();
  BoolColumn get isDarkMode => boolean().withDefault(const Constant(false))();
  TextColumn get language => text().withDefault(const Constant('id'))();
  DateTimeColumn get lastBackup => dateTime().nullable()();
}
