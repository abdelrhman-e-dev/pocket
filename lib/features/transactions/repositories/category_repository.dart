import '../../../core/database/app_database.dart';

class CategoryRepository {
  CategoryRepository(this._database);

  final AppDatabase _database;

  Future<List<Category>> getCategoriesByType(String type) {
    return (_database.select(_database.categories)
          ..where((category) => category.type.equals(type)))
        .get();
  }
}