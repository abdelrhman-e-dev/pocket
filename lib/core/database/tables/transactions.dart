import 'package:drift/drift.dart';

import 'accounts.dart';
import 'categories.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get accountId =>
      integer().references(Accounts, #id)();

  IntColumn get categoryId =>
      integer().references(Categories, #id)();

  TextColumn get type => text()();

  RealColumn get amount => real()();

  TextColumn get note => text().nullable()();

  DateTimeColumn get transactionDate => dateTime()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}