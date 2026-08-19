import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/models/transaction_period_filter.dart';

final reportPeriodFilterProvider =
    StateProvider<TransactionPeriodFilter>((ref) {
  return TransactionPeriodFilter.thisMonth;
});

final reportCustomDateRangeProvider =
    StateProvider<DateTimeRange?>((ref) {
  return null;
});