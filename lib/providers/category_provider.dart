import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/database/categories_dao.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:titik_waktu/repositories/category_repository.dart';

/// CategoriesDao provider
final categoriesDaoProvider = Provider<CategoriesDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.categoriesDao;
});

/// CategoryRepository provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dao = ref.watch(categoriesDaoProvider);
  return CategoryRepository(dao);
});

/// Category list StreamProvider for auto-updating UI
final categoryListProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchAllCategories();
});

/// Category map provider for easy lookup by ID: Map<int, Category>
final categoryMapProvider = Provider<Map<int, Category>>((ref) {
  final categoriesAsync = ref.watch(categoryListProvider);
  return categoriesAsync.when(
    data: (categories) => {for (var c in categories) c.id: c},
    loading: () => {},
    error: (_, __) => {},
  );
});
