import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../services/database_initializer.dart';
import 'categories_dao.dart';
import 'schedules_dao.dart';

part 'database.g.dart';

@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get colorHex => text()();
}

@DataClassName('Schedule')
class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get time => dateTime()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  IntColumn get notificationType => integer().nullable().withDefault(const Constant(0))();
  TextColumn get soundPath => text().nullable()();
  IntColumn get color => integer().nullable().withDefault(const Constant(0xFFFFFFFF))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get recurrenceType => integer().nullable().withDefault(const Constant(0))();
  TextColumn get recurrenceRule => text().nullable()();
  IntColumn get interval => integer().nullable()();
  IntColumn get daysOfWeek => integer().nullable()();
  IntColumn get dayOfMonth => integer().nullable()();
  IntColumn get monthPattern => integer().nullable()();
  IntColumn get endCount => integer().nullable()();
  TextColumn get exceptionDates => text().nullable()();
  TextColumn get rescheduledDates => text().nullable()();
  IntColumn get categoryId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('HistoryLog')
class HistoryLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get action => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Schedules, HistoryLogs, Categories], daos: [SchedulesDao, CategoriesDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => DatabaseInitializer.dbVersion;

  @override
  MigrationStrategy get migration => DatabaseInitializer().strategy(this);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() {
    return _instance;
  }
  
  DatabaseService._internal();

  AppDatabase? _database;

  /// Gets the database instance, initializing it if necessary.
  Future<AppDatabase> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = AppDatabase();
    return _database!;
  }

  /// Closes the database connection.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Re-initializes the database connection.
  Future<void> resetDatabase() async {
    await close();
    _database = AppDatabase();
  }

  /// Helper methods for basic database operations
  /// Adapted for Drift using custom statements for backward compatibility
  
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    var sql = 'SELECT * FROM $table';
    if (where != null) {
      sql += ' WHERE $where';
    }
    final vars = whereArgs?.map((v) => Variable(v)).toList() ?? const [];
    final result = await db.customSelect(sql, variables: vars).get();
    return result.map((row) => row.data).toList();
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    final keys = data.keys.join(', ');
    final variables = data.values.map((_) => '?').join(', ');
    return await db.customInsert(
      'INSERT INTO $table ($keys) VALUES ($variables)',
      variables: data.values.map((v) => Variable(v)).toList(),
    );
  }

  Future<int> update(String table, Map<String, dynamic> data, {required String where, required List<Object?> whereArgs}) async {
    final db = await database;
    final setClause = data.keys.map((k) => "$k = ?").join(', ');
    final args = [...data.values, ...whereArgs];
    return await db.customUpdate(
      'UPDATE $table SET $setClause WHERE $where',
      variables: args.map((v) => Variable(v)).toList(),
    );
  }

  Future<int> delete(String table, {required String where, required List<Object?> whereArgs}) async {
    final db = await database;
    return await db.customUpdate(
      'DELETE FROM $table WHERE $where',
      variables: whereArgs.map((v) => Variable(v)).toList(),
    );
  }
}
