import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/providers/account_repository_provider.dart';

final dashboardProvider = FutureProvider((ref) {
  final repository = ref.watch(accountRepositoryProvider);

  return repository.getAccounts();
});