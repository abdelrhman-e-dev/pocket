import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity_item.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_period_filter.dart';
import 'activity_provider.dart';
import 'transaction_filter_provider.dart';
import 'transaction_period_filter_provider.dart';

final filteredActivitiesProvider =
    Provider<AsyncValue<List<ActivityItem>>>((ref) {
  final activitiesAsync = ref.watch(activityProvider);

  final typeFilter = ref.watch(transactionFilterProvider);
  final periodFilter = ref.watch(transactionPeriodFilterProvider);
  final customRange = ref.watch(customTransactionDateRangeProvider);

  return activitiesAsync.whenData((items) {
    var result = items;

    // =========================
    // Filter by type
    // =========================

    switch (typeFilter) {
      case TransactionFilter.all:
        break;

      case TransactionFilter.expense:
        result = result.where((item) {
          return item.transaction?.transaction.type == 'expense';
        }).toList();
        break;

      case TransactionFilter.income:
        result = result.where((item) {
          return item.transaction?.transaction.type == 'income';
        }).toList();
        break;

      case TransactionFilter.transfer:
        result = result.where((item) {
          return item.type == ActivityType.transfer;
        }).toList();
        break;
    }

    // =========================
    // Filter by date period
    // =========================

    final now = DateTime.now();

    DateTime start;
    DateTime end;

    switch (periodFilter) {
      case TransactionPeriodFilter.today:
        start = DateTime(
          now.year,
          now.month,
          now.day,
        );

        end = start.add(
          const Duration(days: 1),
        );
        break;

      case TransactionPeriodFilter.thisWeek:
        final today = DateTime(
          now.year,
          now.month,
          now.day,
        );

        final daysFromMonday =
            today.weekday - DateTime.monday;

        start = today.subtract(
          Duration(days: daysFromMonday),
        );

        end = start.add(
          const Duration(days: 7),
        );
        break;

      case TransactionPeriodFilter.thisMonth:
        start = DateTime(
          now.year,
          now.month,
          1,
        );

        end = DateTime(
          now.year,
          now.month + 1,
          1,
        );
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
        ).add(
          const Duration(days: 1),
        );
        break;
    }

    result = result.where((item) {
      final date = item.date;

      return !date.isBefore(start) &&
          date.isBefore(end);
    }).toList();

    // activityProvider already sorts by date,
    // but we keep the ordering guaranteed here.
    result.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    return result;
  });
});