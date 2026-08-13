import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_filter.dart';
import '../models/transaction_period_filter.dart';
import '../models/transaction_with_details.dart';
import 'all_transactions_provider.dart';
import 'transaction_filter_provider.dart';
import 'transaction_period_filter_provider.dart';

final filteredTransactionsProvider =
    Provider<AsyncValue<List<TransactionWithDetails>>>((ref) {
  final transactionsAsync = ref.watch(allTransactionsWithDetailsProvider);

  final typeFilter = ref.watch(transactionFilterProvider);
  final periodFilter = ref.watch(transactionPeriodFilterProvider);
  final customRange = ref.watch(customTransactionDateRangeProvider);

  return transactionsAsync.whenData((items) {
    var result = items;

    // =========================
    // Filter by transaction type
    // =========================
    final type = typeFilter.dbType;

    if (type != null) {
      result = result
          .where((item) => item.transaction.type == type)
          .toList();
    }

    // =========================
    // Filter by date period
    // =========================
    final now = DateTime.now();

    DateTime start;
    DateTime end;

    switch (periodFilter) {
      case TransactionPeriodFilter.today:
        start = DateTime(now.year, now.month, now.day);
        end = start.add(const Duration(days: 1));
        break;

      case TransactionPeriodFilter.thisWeek:
        final today = DateTime(now.year, now.month, now.day);

        // Monday = 1
        final daysFromMonday = today.weekday - DateTime.monday;

        start = today.subtract(
          Duration(days: daysFromMonday),
        );

        end = start.add(const Duration(days: 7));
        break;

      case TransactionPeriodFilter.thisMonth:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 1);
        break;

      case TransactionPeriodFilter.custom:
        if (customRange == null) {
          return result;
        }

        start = DateTime(
          customRange.start.year,
          customRange.start.month,
          customRange.start.day,
        );

        end = DateTime(
          customRange.end.year,
          customRange.end.month,
          customRange.end.day,
        ).add(const Duration(days: 1));
        break;
    }

    result = result.where((item) {
      final date = item.transaction.transactionDate;

      return !date.isBefore(start) && date.isBefore(end);
    }).toList();

    return result;
  });
});