import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_with_details.dart';
import 'transaction_repository_provider.dart';

final allTransactionsWithDetailsProvider =
    FutureProvider<List<TransactionWithDetails>>((ref) {
      final repository = ref.watch(transactionRepositoryProviderPage);

      return repository.getAllTransactionsWithDetails();
    });
