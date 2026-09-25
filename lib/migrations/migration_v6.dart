import 'package:drift/drift.dart';
import 'migration.dart';

class MigrationV6 extends Migration {
  MigrationV6() : super(6);

  @override
  Future<void> up(Migrator m, GeneratedDatabase db) async {
    print('Executing MigrationV6 UP: Making schedules.time nullable and adding categories.cover_image_uri...');

    // 1. Add cover_image_uri to categories table
    try {
      await db.customStatement('ALTER TABLE categories ADD COLUMN cover_image_uri TEXT');
    } catch (e) {
      print('Note: cover_image_uri column may already exist: $e');
    }

    // 2. Recreate schedules table to make `time` column nullable while preserving all existing data
    try {
      await db.transaction(() async {
        await db.customStatement('''
          CREATE TABLE IF NOT EXISTS schedules_temp (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            time INTEGER,
            start_date INTEGER,
            end_date INTEGER,
            notification_type INTEGER DEFAULT 0,
            sound_path TEXT,
            color INTEGER DEFAULT 4294967295,
            is_active INTEGER NOT NULL DEFAULT 1,
            recurrence_type INTEGER DEFAULT 0,
            recurrence_rule TEXT,
            interval INTEGER,
            days_of_week INTEGER,
            day_of_month INTEGER,
            month_pattern INTEGER,
            end_count INTEGER,
            exception_dates TEXT,
            rescheduled_dates TEXT,
            category_id INTEGER,
            created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
            updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
          )
        ''');

        await db.customStatement('''
          INSERT INTO schedules_temp (
            id, title, description, time, start_date, end_date,
            notification_type, sound_path, color, is_active,
            recurrence_type, recurrence_rule, interval, days_of_week,
            day_of_month, month_pattern, end_count, exception_dates,
            rescheduled_dates, category_id, created_at, updated_at
          )
          SELECT 
            id, title, description, time, start_date, end_date,
            notification_type, sound_path, color, is_active,
            recurrence_type, recurrence_rule, interval, days_of_week,
            day_of_month, month_pattern, end_count, exception_dates,
            rescheduled_dates, category_id, created_at, updated_at
          FROM schedules
        ''');

        await db.customStatement('DROP TABLE schedules');
        await db.customStatement('ALTER TABLE schedules_temp RENAME TO schedules');
      });
      print('schedules table rebuilt successfully with nullable time column.');
    } catch (e) {
      print('Note: schedules table alteration error or already migrated: $e');
    }

    print('MigrationV6 UP completed.');
  }

  @override
  Future<void> down(Migrator m, GeneratedDatabase db) async {
    print('MigrationV6 DOWN: SQLite does not drop columns directly.');
  }
}
