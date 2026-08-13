import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import 'transaction_repository_provider.dart';

final recentTransactionsProvider =
    FutureProvider<List<Transaction>>((ref) {
  final repository = ref.watch(transactionRepositoryProviderPage);

  return repository.getRecentTransactions();
});