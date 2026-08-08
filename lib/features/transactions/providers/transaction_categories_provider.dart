import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_type.dart';
import 'category_repository_provider.dart';
import '../../../core/database/app_database.dart';
final transactionCategoriesProvider =
    FutureProvider.family<List<Category>, TransactionType>(
  (ref, transactionType) async {
    final repository = ref.watch(categoryRepositoryProvider);

    final type = transactionType == TransactionType.expense
        ? 'expense'
        : 'income';

    return repository.getCategoriesByType(type);
  },
);