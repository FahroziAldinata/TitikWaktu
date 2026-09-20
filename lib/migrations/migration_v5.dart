import 'package:drift/drift.dart';
import 'migration.dart';

class MigrationV5 extends Migration {
  MigrationV5() : super(5);

  @override
  Future<void> up(Migrator m, GeneratedDatabase db) async {
    print('Executing MigrationV5 UP: Adding ringtone_uri to categories table...');

    try {
      await db.customStatement('ALTER TABLE categories ADD COLUMN ringtone_uri TEXT');
    } catch (e) {
      print('Note: ringtone_uri column may already exist or table altered: $e');
    }

    print('MigrationV5 UP completed.');
  }

  @override
  Future<void> down(Migrator m, GeneratedDatabase db) async {
    print('MigrationV5 DOWN: Note SQLite does not support dropping columns easily.');
  }
}
