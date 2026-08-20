import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return CategoryRepository(database);
});
final allCategoriesProvider = FutureProvider((ref) {
  final repository = ref.watch(categoryRepositoryProvider);

  return repository.getAllCategories();
});
