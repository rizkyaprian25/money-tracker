import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/app_database.dart';
import 'dashboard_provider.dart';
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
  final Ref ref;
  CategoryNotifier(this.db, this.ref);

  Future<int> addCategory(String name, String type, String color, String icon) async {
    final id = await db.insertCategory(CategoriesCompanion.insert(
      name: name,
      type: type,
      color: color,
      icon: icon,
    ));
    _refreshSummaries();
    return id;
  }

  Future<bool> updateCategory(Category category) async {
    final ok = await db.updateCategory(category);
    _refreshSummaries();
    return ok;
  }

  Future<int> deleteCategory(int id) async {
    final count = await db.deleteCategory(id);
    _refreshSummaries();
    return count;
  }

  /// Nama/warna kategori tampil di dashboard & tile -> refresh otomatis.
  void _refreshSummaries() {
    ref.invalidate(dashboardProvider);
    ref.invalidate(categoriesFutureProvider);
  }
}

final categoryNotifierProvider = Provider<CategoryNotifier>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryNotifier(db, ref);
});
