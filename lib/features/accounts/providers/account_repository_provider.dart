import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/account_repository.dart';
import '../../../core/database/database_provider.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return AccountRepository(database);
});

final accountsProvider = FutureProvider((ref) {
  final repository = ref.watch(accountRepositoryProvider);

  return repository.getAccounts();
});
