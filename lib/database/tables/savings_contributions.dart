import 'package:drift/drift.dart';

class SavingsContributions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer().customConstraint('NOT NULL REFERENCES savings_goals(id) ON DELETE CASCADE')();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
}
