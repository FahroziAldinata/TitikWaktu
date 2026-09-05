import 'package:drift/drift.dart';
import '../models/schedule.dart';
import 'database.dart';

part 'schedules_dao.g.dart';

/// Data Access Object for Schedules table
/// 
/// Provides CRUD operations for Schedule entities with proper error handling
@DriftAccessor(tables: [Schedules])
class SchedulesDao extends DatabaseAccessor<AppDatabase> with _$SchedulesDaoMixin {
  SchedulesDao(AppDatabase db) : super(db);

  /// Insert a new schedule
  Future<Schedule> insertSchedule(SchedulesCompanion schedule) async {
    try {
      await into(schedules).insert(schedule);
      return (select(schedules)..where((t) => t.id.equals(schedule.id.value))).getSingle();
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to insert schedule: ${e.toString()}', stackTrace);
    }
  }

  /// Update an existing schedule
  Future<Schedule> updateSchedule(SchedulesCompanion schedule) async {
    try {
      await update(schedules).replace(schedule);
      return (select(schedules)..where((t) => t.id.equals(schedule.id.value))).getSingle();
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to update schedule: ${e.toString()}', stackTrace);
    }
  }

  /// Delete a schedule by ID
  Future<int> deleteSchedule(String id) async {
    try {
      return await (delete(schedules)..where((t) => t.id.equals(id))).go();
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to delete schedule: ${e.toString()}', stackTrace);
    }
  }

  /// Get a schedule by ID
  Future<Schedule?> getScheduleById(String id) async {
    try {
      return (select(schedules)..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to get schedule by ID: ${e.toString()}', stackTrace);
    }
  }

  /// Get all schedules
  Future<List<Schedule>> getAllSchedules() async {
    try {
      return await select(schedules).get();
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to get all schedules: ${e.toString()}', stackTrace);
    }
  }

  /// Get active schedules only
  Future<List<Schedule>> getActiveSchedules() async {
    try {
      return await (select(schedules)
        ..where((t) => t.isActive.equals(true))
        ..orderBy([
          (t) => OrderingTerm(expression: t.time),
        ])).get();
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to get active schedules: ${e.toString()}', stackTrace);
    }
  }

  /// Get schedules for a specific date
  Future<List<Schedule>> getSchedulesByDate(DateTime date) async {
    try {
      // Convert date to start and end of day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
      
      return await (select(schedules)
        ..where((t) => t.time.isBetween(Variable(startOfDay), Variable(endOfDay)))
        ..orderBy([
          (t) => OrderingTerm(expression: t.time),
        ])).get();
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to get schedules by date: ${e.toString()}', stackTrace);
    }
  }

  /// Get schedules for a date range
  Future<List<Schedule>> getSchedulesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return await (select(schedules)
        ..where((t) => t.time.isBetween(Variable(startDate), Variable(endDate)))
        ..orderBy([
          (t) => OrderingTerm(expression: t.time),
        ])).get();
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to get schedules by date range: ${e.toString()}', stackTrace);
    }
  }

  /// Get schedules by notification type
  Future<List<Schedule>> getSchedulesByNotificationType(NotificationType type) async {
    try {
      return await (select(schedules)
        ..where((t) => t.notificationType.equals(type.index))
        ..orderBy([
          (t) => OrderingTerm(expression: t.time),
        ])).get();
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to get schedules by notification type: ${e.toString()}', stackTrace);
    }
  }

  /// Get schedules by recurrence type
  Future<List<Schedule>> getSchedulesByRecurrenceType(RecurrenceType type) async {
    try {
      return await (select(schedules)
        ..where((t) => t.recurrenceType.equals(type.index))
        ..orderBy([
          (t) => OrderingTerm(expression: t.time),
        ])).get();
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to get schedules by recurrence type: ${e.toString()}', stackTrace);
    }
  }

  /// Get schedules for today
  Future<List<Schedule>> getTodaysSchedules() async {
    try {
      final now = DateTime.now();
      return await getSchedulesByDate(now);
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to get today\'s schedules: ${e.toString()}', stackTrace);
    }
  }

  /// Get schedules for this week
  Future<List<Schedule>> getThisWeeksSchedules() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      
      return await getSchedulesByDateRange(startOfWeek, endOfWeek);
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to get this week\'s schedules: ${e.toString()}', stackTrace);
    }
  }

  /// Get schedules for this month
  Future<List<Schedule>> getThisMonthsSchedules() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      return await getSchedulesByDateRange(startOfMonth, endOfMonth);
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to get this month\'s schedules: ${e.toString()}', stackTrace);
    }
  }

  /// Check if a schedule exists by ID
  Future<bool> scheduleExists(String id) async {
    try {
      final schedule = await getScheduleById(id);
      return schedule != null;
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to check schedule existence: ${e.toString()}', stackTrace);
    }
  }

  /// Get schedule count
  Future<int> getScheduleCount() async {
    try {
      return await select(schedules).get().then((schedules) => schedules.length);
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to get schedule count: ${e.toString()}', stackTrace);
    }
  }

  /// Get active schedule count
  Future<int> getActiveScheduleCount() async {
    try {
      return await (select(schedules)
        ..where((t) => t.isActive.equals(true)))
        .get()
        .then((schedules) => schedules.length);
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to get active schedule count: ${e.toString()}', stackTrace);
    }
  }

  /// Deactivate a schedule (soft delete)
  Future<int> deactivateSchedule(String id) async {
    try {
      return await (update(schedules)
        ..where((t) => t.id.equals(id)))
        .write(const SchedulesCompanion(isActive: Value(false)));
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to deactivate schedule: ${e.toString()}', stackTrace);
    }
  }

  /// Activate a schedule
  Future<int> activateSchedule(String id) async {
    try {
      return await (update(schedules)
        ..where((t) => t.id.equals(id)))
        .write(const SchedulesCompanion(isActive: Value(true)));
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to activate schedule: ${e.toString()}', stackTrace);
    }
  }

  /// Update schedule timestamps
  Future<int> updateScheduleTimestamps(String id) async {
    try {
      final now = DateTime.now();
      return await (update(schedules)
        ..where((t) => t.id.equals(id)))
        .write(SchedulesCompanion(
          updatedAt: Value(now),
          createdAt: const Value.absent(), // Don't update created time
        ));
    } catch (e, stackTrace) {
      throw DatabaseException('Failed to update schedule timestamps: ${e.toString()}', stackTrace);
    }
  }
}

/// Custom exception for database operations
class DatabaseException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  DatabaseException(this.message, this.stackTrace);

  @override
  String toString() => 'DatabaseException: $message';
}