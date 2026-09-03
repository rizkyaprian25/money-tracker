import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // income / expense
  TextColumn get color => text()(); // hex e.g. #24389C
  TextColumn get icon => text()(); // material icon name
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
