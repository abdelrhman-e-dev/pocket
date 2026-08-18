import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class AccountRepository {
  AccountRepository(this._database);

  final AppDatabase _database;

  // ============================================================
  // Create Account
  // ============================================================

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

  // ============================================================
  // Update Account
  // ============================================================

  Future<void> updateAccount({
    required int accountId,
    required String name,
    required String type,
    required int color,
    required String icon,
  }) async {
    await (_database.update(
      _database.accounts,
    )..where(
        (table) => table.id.equals(accountId),
      )).write(
      AccountsCompanion(
        name: Value(name),
        type: Value(type),
        color: Value(color),
        icon: Value(icon),
      ),
    );
  }

  // ============================================================
  // Delete Account
  // ============================================================

  Future<void> deleteAccount(int accountId) async {
    await _database.transaction(() async {
      await (_database.delete(_database.transactions)..where(
            (table) => table.accountId.equals(accountId),
          ))
          .go();

      await (_database.delete(_database.transfers)..where(
            (table) =>
                table.fromAccountId.equals(accountId) |
                table.toAccountId.equals(accountId),
          ))
          .go();

      await (_database.delete(_database.accounts)..where(
            (table) => table.id.equals(accountId),
          ))
          .go();
    });
  }

  // ============================================================
  // Get Accounts
  // ============================================================

  Future<List<Account>> getAccounts() {
    return _database.select(_database.accounts).get();
  }

  // ============================================================
  // Get Account By ID
  // ============================================================

  Future<Account> getAccountById(int accountId) {
    return (_database.select(
      _database.accounts,
    )..where(
        (table) => table.id.equals(accountId),
      )).getSingle();
  }
}