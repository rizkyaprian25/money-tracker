import 'package:drift/drift.dart';

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().nullable().customConstraint('REFERENCES categories(id) ON DELETE CASCADE')();
  RealColumn get amount => real()();
  IntColumn get month => integer()(); // 1-12
  IntColumn get year => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
