import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../repositories/transfer_repository.dart';

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return TransferRepository(database);
});