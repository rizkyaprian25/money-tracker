import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/repository_providers.dart';
import '../../domain/entities/category_entity.dart';

/// Clean-architecture category provider — uses `CategoryRepository`.

final categoriesStreamEntityProvider = StreamProvider<List<CategoryEntity>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchCategories();
});

final categoriesByTypeEntityProvider =
    StreamProvider.family<List<CategoryEntity>, String>((ref, type) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchCategoriesByType(type);
});

final categoriesFutureEntityProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories();
});

class CategoryEntityNotifier {
  final dynamic repo; // CategoryRepository
  CategoryEntityNotifier(this.repo);

  Future<int> addCategory(String name, String type, String color, String icon) =>
      repo.insertCategory(name, type, color, icon);

  Future<bool> updateCategory(CategoryEntity entity) => repo.updateCategory(entity);

  Future<int> deleteCategory(int id) => repo.deleteCategory(id);
}

final categoryEntityNotifierProvider = Provider<CategoryEntityNotifier>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return CategoryEntityNotifier(repo);
});
