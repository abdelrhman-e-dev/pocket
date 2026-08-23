import 'package:drift/drift.dart';

class UserProfiles extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
