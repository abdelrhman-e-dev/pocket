import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../repositories/reports_repository.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return ReportsRepository(database);
});