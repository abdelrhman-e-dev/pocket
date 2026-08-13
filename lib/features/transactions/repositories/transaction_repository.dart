import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../models/transaction_with_details.dart';

class TransactionRepository {
  TransactionRepository(this._database);

  final AppDatabase _database;

  Future<void> createTransaction({
    required int accountId,
    required int categoryId,
    required String type,
    required double amount,
    String? note,
    required DateTime transactionDate,
  }) async {
    await _database.transaction(() async {
      // 1 - save the transaction
      await _database
          .into(_database.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              categoryId: categoryId,
              type: type,
              amount: amount,
              note: Value(note),
              transactionDate: transactionDate,
            ),
          );

      // 2 - read the account
      final account = await (_database.select(
        _database.accounts,
      )..where((table) => table.id.equals(accountId))).getSingle();

      // 3 - calculate the new balance
      final newBalance = type == 'expense'
          ? account.currentBalance - amount
          : account.currentBalance + amount;

      // 4 - update the account balance
      await (_database.update(_database.accounts)
            ..where((table) => table.id.equals(accountId)))
          .write(AccountsCompanion(currentBalance: Value(newBalance)));
    });
  }

  Future<void> updateTransaction({
    required int transactionId,
    required int accountId,
    required int categoryId,
    required String type,
    required double amount,
    String? note,
    required DateTime transactionDate,
  }) async {
    await _database.transaction(() async {
      // 1. Get the old transaction
      final oldTransaction = await (_database.select(
        _database.transactions,
      )..where((table) => table.id.equals(transactionId))).getSingle();

      // 2. Get the old account
      final oldAccount =
          await (_database.select(_database.accounts)
                ..where((table) => table.id.equals(oldTransaction.accountId)))
              .getSingle();

      // 3. Restore the old transaction effect
      //
      // Old expense:
      // account was reduced -> add it back
      //
      // Old income:
      // account was increased -> subtract it
      final restoredBalance = oldTransaction.type == 'expense'
          ? oldAccount.currentBalance + oldTransaction.amount
          : oldAccount.currentBalance - oldTransaction.amount;

      // 4. If the account changed, restore the old
      // account first.
      await (_database.update(_database.accounts)
            ..where((table) => table.id.equals(oldTransaction.accountId)))
          .write(AccountsCompanion(currentBalance: Value(restoredBalance)));

      // 5. Update the transaction itself
      await (_database.update(
        _database.transactions,
      )..where((table) => table.id.equals(transactionId))).write(
        TransactionsCompanion(
          accountId: Value(accountId),
          categoryId: Value(categoryId),
          type: Value(type),
          amount: Value(amount),
          note: Value(note),
          transactionDate: Value(transactionDate),
        ),
      );

      // 6. Get the new account
      final newAccount = await (_database.select(
        _database.accounts,
      )..where((table) => table.id.equals(accountId))).getSingle();

      // 7. Apply the new transaction effect
      final newBalance = type == 'expense'
          ? newAccount.currentBalance - amount
          : newAccount.currentBalance + amount;

      // 8. Update the new account balance
      await (_database.update(_database.accounts)
            ..where((table) => table.id.equals(accountId)))
          .write(AccountsCompanion(currentBalance: Value(newBalance)));
    });
  }
Future<void> deleteTransaction({
  required int transactionId,
}) async {
  await _database.transaction(() async {
    // 1. Get the transaction before deleting it.
    final transaction = await (_database.select(
      _database.transactions,
    )..where(
        (table) => table.id.equals(transactionId),
      )).getSingle();

    // 2. Get the account affected by this transaction.
    final account = await (_database.select(
      _database.accounts,
    )..where(
        (table) => table.id.equals(transaction.accountId),
      )).getSingle();

    // 3. Restore the account balance.
    final restoredBalance =
        transaction.type == 'expense'
            ? account.currentBalance + transaction.amount
            : account.currentBalance - transaction.amount;

    // 4. Restore the balance.
    await (_database.update(
      _database.accounts,
    )..where(
        (table) => table.id.equals(transaction.accountId),
      )).write(
      AccountsCompanion(
        currentBalance: Value(restoredBalance),
      ),
    );

    // 5. Delete the transaction.
    await (_database.delete(
      _database.transactions,
    )..where(
        (table) => table.id.equals(transactionId),
      )).go();
  });
}
  Future<List<Transaction>> getRecentTransactions({int limit = 5}) async {
    return (_database.select(_database.transactions)
          ..orderBy([
            (table) => OrderingTerm(
              expression: table.transactionDate,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit))
        .get();
  }

  Future<List<TransactionWithDetails>> getRecentTransactionsWithDetails({
    int limit = 5,
  }) async {
    final query = _database.select(_database.transactions).join([
      innerJoin(
        _database.accounts,
        _database.accounts.id.equalsExp(_database.transactions.accountId),
      ),
      innerJoin(
        _database.categories,
        _database.categories.id.equalsExp(_database.transactions.categoryId),
      ),
    ]);

    query
      ..orderBy([
        OrderingTerm(
          expression: _database.transactions.transactionDate,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);

    final rows = await query.get();

    return rows.map((row) {
      return TransactionWithDetails(
        transaction: row.readTable(_database.transactions),
        account: row.readTable(_database.accounts),
        category: row.readTable(_database.categories),
      );
    }).toList();
  }

  Future<List<TransactionWithDetails>> getTransactionsWithDetails({
    String? type,
    int limit = 10,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = _database.select(_database.transactions).join([
      innerJoin(
        _database.accounts,
        _database.accounts.id.equalsExp(_database.transactions.accountId),
      ),
      innerJoin(
        _database.categories,
        _database.categories.id.equalsExp(_database.transactions.categoryId),
      ),
    ]);

    // فلترة حسب النوع
    if (type != null) {
      query.where(_database.transactions.type.equals(type));
    }

    // بداية الفترة
    if (startDate != null) {
      query.where(
        _database.transactions.transactionDate.isBiggerOrEqualValue(startDate),
      );
    }

    // نهاية الفترة
    if (endDate != null) {
      query.where(
        _database.transactions.transactionDate.isSmallerThanValue(endDate),
      );
    }

    query
      ..orderBy([
        OrderingTerm(
          expression: _database.transactions.transactionDate,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit, offset: offset);

    final rows = await query.get();

    return rows.map((row) {
      return TransactionWithDetails(
        transaction: row.readTable(_database.transactions),
        account: row.readTable(_database.accounts),
        category: row.readTable(_database.categories),
      );
    }).toList();
  }

  Future<List<TransactionWithDetails>> getAllTransactionsWithDetails({
    String? type,
  }) async {
    return getTransactionsWithDetails(type: type, limit: 100000, offset: 0);
  }

  Future<double> getCurrentMonthExpenses() async {
    final now = DateTime.now();

    final startOfMonth = DateTime(now.year, now.month, 1);

    final startOfNextMonth = DateTime(now.year, now.month + 1, 1);

    final query = _database.select(_database.transactions)
      ..where(
        (table) =>
            table.type.equals('expense') &
            table.transactionDate.isBiggerOrEqualValue(startOfMonth) &
            table.transactionDate.isSmallerThanValue(startOfNextMonth),
      );

    final transactions = await query.get();

    return transactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );
  }

  Future<double> getCurrentMonthIncome() async {
    final now = DateTime.now();

    final startOfMonth = DateTime(now.year, now.month, 1);

    final startOfNextMonth = DateTime(now.year, now.month + 1, 1);

    final query = _database.select(_database.transactions)
      ..where(
        (table) =>
            table.type.equals('income') &
            table.transactionDate.isBiggerOrEqualValue(startOfMonth) &
            table.transactionDate.isSmallerThanValue(startOfNextMonth),
      );

    final transactions = await query.get();

    return transactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );
  }
}
