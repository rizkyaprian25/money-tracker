import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Stream<List<CategoryEntity>> watchCategories();
  Stream<List<CategoryEntity>> watchCategoriesByType(String type);
  Future<List<CategoryEntity>> getCategories();
  Future<List<CategoryEntity>> getCategoriesByType(String type);
  Future<int> insertCategory(String name, String type, String color, String icon);
  Future<bool> updateCategory(CategoryEntity entity);
  Future<int> deleteCategory(int id);
}
