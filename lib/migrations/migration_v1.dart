import 'package:drift/drift.dart';
import 'migration.dart';

class MigrationV1 extends Migration {
  MigrationV1() : super(1);

  @override
  Future<void> up(Migrator m, GeneratedDatabase db) async {
    await db.customStatement('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    print('Migration v1 up executed.');
  }

  @override
  Future<void> down(GeneratedDatabase db) async {
    await db.customStatement('DROP TABLE IF EXISTS users');
    print('Migration v1 down executed.');
  }
}
