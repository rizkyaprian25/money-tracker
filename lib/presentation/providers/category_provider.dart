import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/app_database.dart';
import 'database_provider.dart';

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCategories();
});

final categoriesByTypeProvider = StreamProvider.family<List<Category>, String>((ref, type) {
  final db = ref.watch(databaseProvider);
  return db.watchCategoriesByType(type);
});

final categoriesFutureProvider = FutureProvider<List<Category>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.select(db.categories).get();
});

class CategoryNotifier {
  final AppDatabase db;
  CategoryNotifier(this.db);

  Future<int> addCategory(String name, String type, String color, String icon) {
    return db.insertCategory(CategoriesCompanion.insert(
      name: name,
      type: type,
      color: color,
      icon: icon,
    ));
  }

  Future<bool> updateCategory(Category category) => db.updateCategory(category);

  Future<int> deleteCategory(int id) => db.deleteCategory(id);
}

final categoryNotifierProvider = Provider<CategoryNotifier>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryNotifier(db);
});
