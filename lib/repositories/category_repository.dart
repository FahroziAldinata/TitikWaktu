import 'package:drift/drift.dart';
import 'package:titik_waktu/database/categories_dao.dart';
import 'package:titik_waktu/database/database.dart';

class CategoryRepository {
  final CategoriesDao _dao;

  CategoryRepository(this._dao);

  /// Get all categories
  Future<List<Category>> getAllCategories() => _dao.getAllCategories();

  /// Watch all categories stream
  Stream<List<Category>> watchAllCategories() => _dao.watchAllCategories();

  /// Get single category by ID
  Future<Category?> getCategoryById(int id) => _dao.getCategoryById(id);

  /// Create a new category
  Future<int> createCategory({
    required String name,
    required String colorHex,
  }) {
    return _dao.insertCategory(
      CategoriesCompanion(
        name: Value(name),
        colorHex: Value(colorHex),
      ),
    );
  }

  /// Update an existing category
  Future<bool> updateCategory({
    required int id,
    required String name,
    required String colorHex,
  }) {
    return _dao.updateCategory(
      CategoriesCompanion(
        id: Value(id),
        name: Value(name),
        colorHex: Value(colorHex),
      ),
    );
  }

  /// Delete a category by ID
  Future<int> deleteCategory(int id) => _dao.deleteCategory(id);
}
