import 'package:drift/drift.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get transactionType => text()(); // income / expense
  IntColumn get categoryId => integer().nullable().customConstraint('NULL REFERENCES categories(id) ON DELETE SET NULL')();
  TextColumn get note => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
