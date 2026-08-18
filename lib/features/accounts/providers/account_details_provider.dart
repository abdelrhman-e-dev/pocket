import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_repository_provider.dart';

final accountDetailsProvider =
    FutureProvider.family((ref, int accountId) {
  final repository = ref.watch(accountRepositoryProvider);

  return repository.getAccountById(accountId);
});