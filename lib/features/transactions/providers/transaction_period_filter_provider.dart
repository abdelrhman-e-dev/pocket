import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/transaction_period_filter.dart';


final transactionPeriodFilterProvider =
    StateProvider<TransactionPeriodFilter>((ref) {
  return TransactionPeriodFilter.thisMonth;
});

final customTransactionDateRangeProvider =
    StateProvider<DateTimeRange?>((ref) {
  return null;
});