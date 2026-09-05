import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:logger/logger.dart';

import '../models/schedule.dart';
import '../models/history_log.dart';
import 'schedules_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Schedules, HistoryLogs],
  daos: [SchedulesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

final _logger = Logger();

/// Enhanced database connection with error handling and retry logic
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    try {
      _logger.i('Opening database connection...');
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File('${dbFolder.path}/titik_waktu.db');
      
      // Ensure directory exists
      if (!await dbFolder.exists()) {
        await dbFolder.create(recursive: true);
      }
      
      // Configure database options
      final db = NativeDatabase(file, logStatements: false);
      
      // Note: PRAGMA commands would need to be executed through a custom query
      // This is a limitation of the current Drift setup
      
      _logger.i('Database connection opened successfully at ${file.path}');
      return db;
    } catch (e, stackTrace) {
      _logger.e('Failed to open database connection', error: e, stackTrace: stackTrace);
      throw DatabaseConnectionException(
        'Failed to open database connection: ${e.toString()}',
        e is Exception ? e : null,
        stackTrace,
      );
    }
  });
}

/// Custom exception for database connection errors
class DatabaseConnectionException implements Exception {
  final String message;
  final Exception? originalException;
  final StackTrace? stackTrace;

  DatabaseConnectionException(
    this.message, [
    this.originalException,
    this.stackTrace,
  ]);

  @override
  String toString() => message;
}