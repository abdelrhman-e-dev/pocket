import 'package:drift/drift.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 50)();

  TextColumn get type => text()();

  RealColumn get openingBalance =>
      real().withDefault(const Constant(0))();

  RealColumn get currentBalance =>
      real().withDefault(const Constant(0))();

  IntColumn get color => integer()();

  TextColumn get icon => text()();

  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}