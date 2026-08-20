import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class CategoryRepository {
  CategoryRepository(this._database);

  final AppDatabase _database;

  Future<List<Category>> getCategoriesByType(String type) {
    return (_database.select(
      _database.categories,
    )..where((category) => category.type.equals(type))).get();
  }

  Future<void> seedDefaultCategories() async {
    final existingCategories = await _database
        .select(_database.categories)
        .get();

    if (existingCategories.isNotEmpty) {
      return;
    }

    await _database.batch((batch) {
      batch.insertAll(_database.categories, [
        CategoriesCompanion.insert(
          name: 'طعام',
          type: 'expense',
          color: 0xFFE57373,
          icon: 'restaurant',
          isSystem: const Value(true),
        ),
        CategoriesCompanion.insert(
          name: 'مواصلات',
          type: 'expense',
          color: 0xFF64B5F6,
          icon: 'directions_car',
          isSystem: const Value(true),
        ),
        CategoriesCompanion.insert(
          name: 'فواتير',
          type: 'expense',
          color: 0xFFFFB74D,
          icon: 'receipt_long',
          isSystem: const Value(true),
        ),
        CategoriesCompanion.insert(
          name: 'تسوق',
          type: 'expense',
          color: 0xFFBA68C8,
          icon: 'shopping_cart',
          isSystem: const Value(true),
        ),
        CategoriesCompanion.insert(
          name: 'ترفيه',
          type: 'expense',
          color: 0xFF4DB6AC,
          icon: 'movie',
          isSystem: const Value(true),
        ),
        CategoriesCompanion.insert(
          name: 'إيجار',
          type: 'expense',
          color: 0xFF7986CB,
          icon: 'home',
          isSystem: const Value(true),
        ),
        CategoriesCompanion.insert(
          name: 'أخرى',
          type: 'expense',
          color: 0xFF90A4AE,
          icon: 'category',
          isSystem: const Value(true),
        ),
        CategoriesCompanion.insert(
          name: 'راتب',
          type: 'income',
          color: 0xFF66BB6A,
          icon: 'payments',
          isSystem: const Value(true),
        ),
        CategoriesCompanion.insert(
          name: 'مكافأة',
          type: 'income',
          color: 0xFFFFCA28,
          icon: 'emoji_events',
          isSystem: const Value(true),
        ),
        CategoriesCompanion.insert(
          name: 'عمل إضافي',
          type: 'income',
          color: 0xFF26A69A,
          icon: 'work',
          isSystem: const Value(true),
        ),
        CategoriesCompanion.insert(
          name: 'تحويل',
          type: 'income',
          color: 0xFF42A5F5,
          icon: 'swap_horiz',
          isSystem: const Value(true),
        ),
        CategoriesCompanion.insert(
          name: 'أخرى',
          type: 'income',
          color: 0xFF90A4AE,
          icon: 'category',
          isSystem: const Value(true),
        ),
      ]);
    });
  }

  Future<List<Category>> getAllCategories() {
    return _database.select(_database.categories).get();
  }

  Future<void> createCategory({
    required String name,
    required String type,
    required int color,
    required String icon,
  }) async {
    await _database
        .into(_database.categories)
        .insert(
          CategoriesCompanion.insert(
            name: name,
            type: type,
            color: color,
            icon: icon,
          ),
        );
  }

  Future<void> updateCategory({
    required int categoryId,
    required String name,
    required int color,
    required String icon,
  }) async {
    await (_database.update(
      _database.categories,
    )..where((table) => table.id.equals(categoryId))).write(
      CategoriesCompanion(
        name: Value(name),
        color: Value(color),
        icon: Value(icon),
      ),
    );
  }

  Future<void> deleteCategory(int categoryId) async {
    final category = await (_database.select(
      _database.categories,
    )..where((table) => table.id.equals(categoryId))).getSingle();

    if (category.isSystem) {
      throw Exception('لا يمكن حذف تصنيف أساسي');
    }

    final hasTransactions = await (_database.select(
      _database.transactions,
    )..where((table) => table.categoryId.equals(categoryId))).getSingleOrNull();

    if (hasTransactions != null) {
      throw Exception('لا يمكن حذف تصنيف لديه معاملات');
    }

    await (_database.delete(
      _database.categories,
    )..where((table) => table.id.equals(categoryId))).go();
  }
}
