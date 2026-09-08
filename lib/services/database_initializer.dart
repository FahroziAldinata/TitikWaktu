import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../migrations/migration.dart';
import '../migrations/migration_v1.dart';
import '../migrations/migration_v2.dart';
import '../migrations/migration_v3.dart';

class DatabaseInitializer {
  static const String _dbName = 'app_database.sqlite';
  static const int dbVersion = 3; // Current database version

  final List<Migration> _migrations = [
    MigrationV1(),
    MigrationV2(),
    MigrationV3(),
  ];

  MigrationStrategy strategy(GeneratedDatabase db) {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        print('Creating database version $dbVersion');
        await m.createAll();
        await _runMigrationsUp(m, db, 0, dbVersion);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        print('Upgrading database from v$from to v$to');
        
        // Backup data before upgrade
        await _backupDatabase();

        try {
          await _runMigrationsUp(m, db, from, to);
          print('Database successfully upgraded to v$to');
        } catch (e) {
          print('Migration failed during upgrade. Error: $e');
          print('Attempting rollback to v$from...');
          await _runMigrationsDown(m, db, to, from);
          throw Exception('Database upgrade failed and rolled back. Error: $e');
        }
      },
      beforeOpen: (details) async {
        if (details.wasCreated) {
          print('Database was created');
        } else if (details.hadUpgrade) {
          print('Database was upgraded');
        }
        
        if (details.versionBefore != null && details.versionBefore! > details.versionNow) {
          print('Downgrading database from v${details.versionBefore} to v${details.versionNow}');
          
          // Backup data before downgrade
          await _backupDatabase();

          try {
            final m = Migrator(db);
            await _runMigrationsDown(m, db, details.versionBefore!, details.versionNow);
            print('Database successfully downgraded to v${details.versionNow}');
          } catch (e) {
            print('Migration failed during downgrade. Error: $e');
            throw Exception('Database downgrade failed. Error: $e');
          }
        }
      },
    );
  }

  Future<void> _runMigrationsUp(Migrator m, GeneratedDatabase db, int oldVersion, int newVersion) async {
    var pendingMigrations = _migrations
        .where((mig) => mig.version > oldVersion && mig.version <= newVersion)
        .toList();
    
    pendingMigrations.sort((a, b) => a.version.compareTo(b.version));
    
    for (var migration in pendingMigrations) {
      print('Running migration UP: v${migration.version}');
      final stopwatch = Stopwatch()..start();
      await migration.up(m, db);
      stopwatch.stop();
      print('Migration UP v${migration.version} completed in ${stopwatch.elapsedMilliseconds}ms.');
    }
  }

  Future<void> _runMigrationsDown(Migrator m, GeneratedDatabase db, int currentVersion, int targetVersion) async {
    var pendingMigrations = _migrations
        .where((mig) => mig.version <= currentVersion && mig.version > targetVersion)
        .toList();
    
    pendingMigrations.sort((a, b) => b.version.compareTo(a.version)); // Descending order
    
    for (var migration in pendingMigrations) {
      print('Running migration DOWN: v${migration.version}');
      final stopwatch = Stopwatch()..start();
      await migration.down(m, db);
      stopwatch.stop();
      print('Migration DOWN v${migration.version} completed in ${stopwatch.elapsedMilliseconds}ms.');
    }
  }

  Future<void> _backupDatabase() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final path = p.join(dbFolder.path, _dbName);
      final backupPath = p.join(dbFolder.path, 'app_database_backup_${DateTime.now().millisecondsSinceEpoch}.sqlite');
      
      final dbFile = File(path);
      if (await dbFile.exists()) {
        await dbFile.copy(backupPath);
        print('Database backup created at $backupPath');
      }
    } catch (e) {
      print('Failed to backup database: $e');
    }
  }
}
