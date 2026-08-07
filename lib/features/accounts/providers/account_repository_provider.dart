import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../repositories/account_repository.dart';

final accountRepositoryProvider =
    Provider<AccountRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return AccountRepository(database);
});