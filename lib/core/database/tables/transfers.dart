import 'package:drift/drift.dart';

import 'accounts.dart';

class Transfers extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get fromAccountId =>
      integer().references(Accounts, #id)();

  IntColumn get toAccountId =>
      integer().references(Accounts, #id)();

  RealColumn get amount => real()();

  TextColumn get note => text().nullable()();

  DateTimeColumn get transferDate => dateTime()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}