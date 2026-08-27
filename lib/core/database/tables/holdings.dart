import 'package:drift/drift.dart';

class Holdings extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get type => text()();

  RealColumn get amount => real()();

  IntColumn get goldKarat => integer().nullable()();

  TextColumn get label => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}