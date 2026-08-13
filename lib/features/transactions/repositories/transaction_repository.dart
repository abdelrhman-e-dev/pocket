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
      _database.accounts.id.equalsExp(
        _database.transactions.accountId,
      ),
    ),
    innerJoin(
      _database.categories,
      _database.categories.id.equalsExp(
        _database.transactions.categoryId,
      ),
    ),
  ]);

  // فلترة حسب النوع
  if (type != null) {
    query.where(
      _database.transactions.type.equals(type),
    );
  }

  // بداية الفترة
  if (startDate != null) {
    query.where(
      _database.transactions.transactionDate
          .isBiggerOrEqualValue(startDate),
    );
  }

  // نهاية الفترة
  if (endDate != null) {
    query.where(
      _database.transactions.transactionDate
          .isSmallerThanValue(endDate),
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
      transaction: row.readTable(
        _database.transactions,
      ),
      account: row.readTable(
        _database.accounts,
      ),
      category: row.readTable(
        _database.categories,
      ),
    );
  }).toList();
}

Future<List<TransactionWithDetails>> getAllTransactionsWithDetails({
  String? type,
}) async {
  return getTransactionsWithDetails(
    type: type,
    limit: 100000,
    offset: 0,
  );
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
