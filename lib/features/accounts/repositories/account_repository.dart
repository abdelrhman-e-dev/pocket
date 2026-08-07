import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
class AccountRepository {
  AccountRepository(this._database);

  final AppDatabase _database;

  Future<void> createAccount({
    required String name,
    required String type,
    required double openingBalance,
    required int color,
    required String icon,
  }) async {
await _database.into(_database.accounts).insert(
  AccountsCompanion.insert(
    name: name,
    type: type,
    openingBalance: Value(openingBalance),
    currentBalance: Value(openingBalance),
    color: color,
    icon: icon,
  ),
);
  }

  Future<List<Account>> getAccounts() {
    return _database.select(_database.accounts).get();
  }
}