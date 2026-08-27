import 'package:drift/drift.dart';

class RateSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();

  RealColumn get usdToEgp => real()();

  RealColumn get goldPricePerGram24k => real()();

  DateTimeColumn get fetchedAt => dateTime()();

  TextColumn get source => text()();
}