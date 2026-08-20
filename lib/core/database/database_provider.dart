import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import '../services/data_management_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final dataManagementServiceProvider = Provider<DataManagementService>((ref) {
  return DataManagementService(ref.watch(databaseProvider));
});
