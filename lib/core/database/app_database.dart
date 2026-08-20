import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/accounts.dart';
import 'tables/categories.dart';
import 'tables/transactions.dart';
import 'tables/transfers.dart';
part 'app_database.g.dart';

@DriftDatabase(
  tables: [Accounts, Categories, Transactions, Transfers],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 1) {
        throw StateError(
          'Unsupported database schema version. Please migrate data with a supported release.',
        );
      }

      // Future schema changes must be added here as incremental, data-preserving
      // migrations such as: if (from < 2) { ... }
      // This keeps existing data intact while allowing upgrades across multiple app versions.
    },
    beforeOpen: (details) async {
      if (details.hadUpgrade) {
        // Keep the current database file intact during normal app updates.
        // Destructive resets are not performed here.
      }

      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();

    final file = File(p.join(dir.path, 'pocket.db'));

    return NativeDatabase.createInBackground(file);
  });
}
