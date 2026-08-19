import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class ReportsRepository {
  ReportsRepository(this._database);

  final AppDatabase _database;

  // ============================================================
  // Total Income
  // ============================================================

  Future<double> getTotalIncome({
    required DateTime start,
    required DateTime end,
  }) async {
    final query = _database.selectOnly(_database.transactions)
      ..addColumns([
        _database.transactions.amount.sum(),
      ])
      ..where(
        _database.transactions.type.equals('income') &
            _database.transactions.transactionDate.isBiggerOrEqualValue(start) &
            _database.transactions.transactionDate.isSmallerThanValue(end),
      );

    final row = await query.getSingle();

    return row.read(_database.transactions.amount.sum()) ?? 0;
  }

  // ============================================================
  // Total Expenses
  // ============================================================

  Future<double> getTotalExpenses({
    required DateTime start,
    required DateTime end,
  }) async {
    final query = _database.selectOnly(_database.transactions)
      ..addColumns([
        _database.transactions.amount.sum(),
      ])
      ..where(
        _database.transactions.type.equals('expense') &
            _database.transactions.transactionDate.isBiggerOrEqualValue(start) &
            _database.transactions.transactionDate.isSmallerThanValue(end),
      );

    final row = await query.getSingle();

    return row.read(_database.transactions.amount.sum()) ?? 0;
  }

  // ============================================================
  // Expense By Category
  // ============================================================

  Future<List<ExpenseByCategory>> getExpensesByCategory({
    required DateTime start,
    required DateTime end,
  }) async {
    final query = _database.selectOnly(_database.transactions).join([
      innerJoin(
        _database.categories,
        _database.categories.id.equalsExp(
          _database.transactions.categoryId,
        ),
      ),
    ])
      ..addColumns([
        _database.categories.id,
        _database.categories.name,
        _database.categories.color,
        _database.categories.icon,
        _database.transactions.amount.sum(),
      ])
      ..where(
        _database.transactions.type.equals('expense') &
            _database.transactions.transactionDate.isBiggerOrEqualValue(start) &
            _database.transactions.transactionDate.isSmallerThanValue(end),
      )
      ..groupBy([
        _database.categories.id,
        _database.categories.name,
        _database.categories.color,
        _database.categories.icon,
      ])
      ..orderBy([
        OrderingTerm(
          expression: _database.transactions.amount.sum(),
          mode: OrderingMode.desc,
        ),
      ]);

    final rows = await query.get();

    return rows.map((row) {
      return ExpenseByCategory(
        categoryId: row.read(_database.categories.id)!,
        categoryName: row.read(_database.categories.name)!,
        color: row.read(_database.categories.color)!,
        icon: row.read(_database.categories.icon)!,
        amount:
            row.read(_database.transactions.amount.sum()) ?? 0,
      );
    }).toList();
  }

  // ============================================================
  // Daily Expenses
  // ============================================================

  Future<List<DailyReport>> getDailyExpenses({
    required DateTime start,
    required DateTime end,
  }) async {
    final transactions = await (_database.select(
      _database.transactions,
    )..where(
        (table) =>
            table.type.equals('expense') &
            table.transactionDate.isBiggerOrEqualValue(start) &
            table.transactionDate.isSmallerThanValue(end),
      )).get();

    final Map<DateTime, double> dailyTotals = {};

    for (final transaction in transactions) {
      final date = DateTime(
        transaction.transactionDate.year,
        transaction.transactionDate.month,
        transaction.transactionDate.day,
      );

      dailyTotals.update(
        date,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final result = dailyTotals.entries
        .map(
          (entry) => DailyReport(
            date: entry.key,
            amount: entry.value,
          ),
        )
        .toList();

    result.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    return result;
  }

  // ============================================================
  // Income & Expense Summary
  // ============================================================

  Future<ReportSummary> getSummary({
    required DateTime start,
    required DateTime end,
  }) async {
    final income = await getTotalIncome(
      start: start,
      end: end,
    );

    final expenses = await getTotalExpenses(
      start: start,
      end: end,
    );

    return ReportSummary(
      income: income,
      expenses: expenses,
      net: income - expenses,
    );
  }
}

// ================================================================
// Models
// ================================================================

class ReportSummary {
  const ReportSummary({
    required this.income,
    required this.expenses,
    required this.net,
  });

  final double income;
  final double expenses;
  final double net;
}

class ExpenseByCategory {
  const ExpenseByCategory({
    required this.categoryId,
    required this.categoryName,
    required this.color,
    required this.icon,
    required this.amount,
  });

  final int categoryId;
  final String categoryName;
  final int color;
  final String icon;
  final double amount;
}

class DailyReport {
  const DailyReport({
    required this.date,
    required this.amount,
  });

  final DateTime date;
  final double amount;
}