import 'package:drift/drift.dart';
import 'migration.dart';

class MigrationV4 extends Migration {
  MigrationV4() : super(4);

  @override
  Future<void> up(Migrator m, GeneratedDatabase db) async {
    print('Executing MigrationV4 UP: Creating categories table and adding category_id to schedules...');

    // 1. Create categories table
    await db.customStatement('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color_hex TEXT NOT NULL
      )
    ''');

    // 2. Add category_id nullable column to schedules table
    try {
      await db.customStatement('ALTER TABLE schedules ADD COLUMN category_id INTEGER');
    } catch (e) {
      print('Note: category_id column may already exist or table altered: $e');
    }

    print('MigrationV4 UP completed.');
  }

  @override
  Future<void> down(Migrator m, GeneratedDatabase db) async {
    print('MigrationV4 DOWN: Dropping categories table...');
    await db.customStatement('DROP TABLE IF EXISTS categories');
    // Note: SQLite does not support dropping columns easily in older versions without table rebuild
    print('MigrationV4 DOWN completed.');
  }
}
