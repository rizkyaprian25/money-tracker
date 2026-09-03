import '../../database/app_database.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../mappers/entity_mapper.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase db;
  CategoryRepositoryImpl(this.db);

  @override
  Stream<List<CategoryEntity>> watchCategories() =>
      db.watchCategories().map((list) => list.map((c) => c.toEntity()).toList());

  @override
  Stream<List<CategoryEntity>> watchCategoriesByType(String type) =>
      db.watchCategoriesByType(type).map((list) => list.map((c) => c.toEntity()).toList());

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final rows = await db.select(db.categories).get();
    return rows.map((c) => c.toEntity()).toList();
  }

  @override
  Future<List<CategoryEntity>> getCategoriesByType(String type) async {
    final rows = await (db.select(db.categories)..where((c) => c.type.equals(type))).get();
    return rows.map((c) => c.toEntity()).toList();
  }

  @override
  Future<int> insertCategory(String name, String type, String color, String icon) =>
      db.insertCategory(CategoriesCompanion.insert(name: name, type: type, color: color, icon: icon));

  @override
  Future<bool> updateCategory(CategoryEntity entity) => db.updateCategory(entity.toDrift());

  @override
  Future<int> deleteCategory(int id) => db.deleteCategory(id);
}
