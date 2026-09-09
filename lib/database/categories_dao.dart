import 'package:drift/drift.dart';
import 'database.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(AppDatabase db) : super(db);

  /// Get all categories sorted by name
  Future<List<Category>> getAllCategories() => (select(categories)..orderBy([(tbl) => OrderingTerm.asc(tbl.name)])).get();

  /// Watch all categories as a Stream
  Stream<List<Category>> watchAllCategories() => (select(categories)..orderBy([(tbl) => OrderingTerm.asc(tbl.name)])).watch();

  /// Get single category by ID
  Future<Category?> getCategoryById(int id) {
    return (select(categories)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Insert a new category
  Future<int> insertCategory(CategoriesCompanion category) => into(categories).insert(category);

  /// Update existing category
  Future<bool> updateCategory(CategoriesCompanion category) => update(categories).replace(category);

  /// Delete category by ID
  Future<int> deleteCategory(int id) => (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
}
