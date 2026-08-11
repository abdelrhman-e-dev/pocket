import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_with_details.dart';
import 'all_transactions_provider.dart';
import 'transaction_filter_provider.dart';

final filteredTransactionsProvider =
    Provider<AsyncValue<List<TransactionWithDetails>>>((ref) {
  final transactionsAsync = ref.watch(allTransactionsWithDetailsProvider);
  final filter = ref.watch(transactionFilterProvider);

  return transactionsAsync.whenData((items) {
    final type = filter.dbType;
    if (type == null) return items;

    return items.where((item) => item.transaction.type == type).toList();
  });
});