import 'package:drift/drift.dart';
import 'migration.dart';

class MigrationV2 extends Migration {
  MigrationV2() : super(2);

  @override
  Future<void> up(Migrator m, GeneratedDatabase db) async {
    // Add is_active column to users table
    await m.issueCustomQuery('''
      ALTER TABLE users ADD COLUMN is_active INTEGER DEFAULT 1;
    ''');
    
    // Create another table for demonstration
    await m.issueCustomQuery('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    print('Migration v2 up executed.');
  }

  @override
  Future<void> down(Migrator m, GeneratedDatabase db) async {
    // Drop the settings table
    await m.issueCustomQuery('DROP TABLE IF EXISTS settings');
    
    // SQLite doesn't natively support dropping columns easily, 
    // but a proper rollback could involve creating a temp table.
    // For simplicity, we just print the issue.
    print('Rollback for ALTER TABLE users DROP COLUMN is_active is complex in SQLite.');
    print('Migration v2 down executed.');
  }
}
