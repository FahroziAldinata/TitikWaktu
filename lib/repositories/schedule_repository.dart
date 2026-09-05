import 'package:logger/logger.dart';
import '../database/schedules_dao.dart';
import '../database/database.dart';
import '../models/schedule.dart';

/// ScheduleRepository - Centralized data access layer for Schedule entities
/// 
/// This repository provides a clean interface for all Schedule-related database operations,
/// including CRUD operations, filtering, and transaction support.
class ScheduleRepository {
  final SchedulesDao _dao;
  final Logger _logger = Logger();

  ScheduleRepository(this._dao);

  /// Insert a new schedule
  Future<Schedule> createSchedule(ScheduleCompanion schedule) async {
    try {
      _logger.i('Creating new schedule: ${schedule.title.value}');
      final createdSchedule = await _dao.insertSchedule(schedule);
      _logger.i('Schedule created successfully: ${createdSchedule.id}');
      return createdSchedule;
    } catch (e, stackTrace) {
      _logger.e('Failed to create schedule', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update an existing schedule
  Future<Schedule> updateSchedule(ScheduleCompanion schedule) async {
    try {
      _logger.i('Updating schedule: ${schedule.id.value}');
      final updatedSchedule = await _dao.updateSchedule(schedule);
      _logger.i('Schedule updated successfully: ${updatedSchedule.id}');
      return updatedSchedule;
    } catch (e, stackTrace) {
      _logger.e('Failed to update schedule', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Delete a schedule by ID
  Future<bool> deleteSchedule(String id) async {
    try {
      _logger.i('Deleting schedule: $id');
      final result = await _dao.deleteSchedule(id);
      _logger.i('Schedule deleted successfully: $id');
      return result > 0;
    } catch (e, stackTrace) {
      _logger.e('Failed to delete schedule', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get a schedule by ID
  Future<Schedule?> getScheduleById(String id) async {
    try {
      _logger.d('Getting schedule by ID: $id');
      final schedule = await _dao.getScheduleById(id);
      _logger.d('Schedule found: ${schedule?.id ?? "null"}');
      return schedule;
    } catch (e, stackTrace) {
      _logger.e('Failed to get schedule by ID', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get all schedules
  Future<List<Schedule>> getAllSchedules() async {
    try {
      _logger.i('Getting all schedules');
      final schedules = await _dao.getAllSchedules();
      _logger.i('Retrieved ${schedules.length} schedules');
      return schedules;
    } catch (e, stackTrace) {
      _logger.e('Failed to get all schedules', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get active schedules only
  Future<List<Schedule>> getActiveSchedules() async {
    try {
      _logger.i('Getting active schedules');
      final schedules = await _dao.getActiveSchedules();
      _logger.i('Retrieved ${schedules.length} active schedules');
      return schedules;
    } catch (e, stackTrace) {
      _logger.e('Failed to get active schedules', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get schedules for a specific date
  Future<List<Schedule>> getSchedulesByDate(DateTime date) async {
    try {
      _logger.i('Getting schedules for date: ${date.toIso8601String()}');
      final schedules = await _dao.getSchedulesByDate(date);
      _logger.i('Retrieved ${schedules.length} schedules for date');
      return schedules;
    } catch (e, stackTrace) {
      _logger.e('Failed to get schedules by date', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get schedules for a date range
  Future<List<Schedule>> getSchedulesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      _logger.i('Getting schedules from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      final schedules = await _dao.getSchedulesByDateRange(startDate, endDate);
      _logger.i('Retrieved ${schedules.length} schedules for date range');
      return schedules;
    } catch (e, stackTrace) {
      _logger.e('Failed to get schedules by date range', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get schedules by notification type
  Future<List<Schedule>> getSchedulesByNotificationType(NotificationType type) async {
    try {
      _logger.i('Getting schedules with notification type: $type');
      final schedules = await _dao.getSchedulesByNotificationType(type);
      _logger.i('Retrieved ${schedules.length} schedules with notification type');
      return schedules;
    } catch (e, stackTrace) {
      _logger.e('Failed to get schedules by notification type', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get schedules by recurrence type
  Future<List<Schedule>> getSchedulesByRecurrenceType(RecurrenceType type) async {
    try {
      _logger.i('Getting schedules with recurrence type: $type');
      final schedules = await _dao.getSchedulesByRecurrenceType(type);
      _logger.i('Retrieved ${schedules.length} schedules with recurrence type');
      return schedules;
    } catch (e, stackTrace) {
      _logger.e('Failed to get schedules by recurrence type', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get schedules for today
  Future<List<Schedule>> getTodaysSchedules() async {
    try {
      _logger.i('Getting today\'s schedules');
      final schedules = await _dao.getTodaysSchedules();
      _logger.i('Retrieved ${schedules.length} schedules for today');
      return schedules;
    } catch (e, stackTrace) {
      _logger.e('Failed to get today\'s schedules', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get schedules for this week
  Future<List<Schedule>> getThisWeeksSchedules() async {
    try {
      _logger.i('Getting this week\'s schedules');
      final schedules = await _dao.getThisWeeksSchedules();
      _logger.i('Retrieved ${schedules.length} schedules for this week');
      return schedules;
    } catch (e, stackTrace) {
      _logger.e('Failed to get this week\'s schedules', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get schedules for this month
  Future<List<Schedule>> getThisMonthsSchedules() async {
    try {
      _logger.i('Getting this month\'s schedules');
      final schedules = await _dao.getThisMonthsSchedules();
      _logger.i('Retrieved ${schedules.length} schedules for this month');
      return schedules;
    } catch (e, stackTrace) {
      _logger.e('Failed to get this month\'s schedules', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Check if a schedule exists by ID
  Future<bool> scheduleExists(String id) async {
    try {
      _logger.d('Checking if schedule exists: $id');
      final exists = await _dao.scheduleExists(id);
      _logger.d('Schedule exists: $exists');
      return exists;
    } catch (e, stackTrace) {
      _logger.e('Failed to check schedule existence', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get schedule count
  Future<int> getScheduleCount() async {
    try {
      _logger.i('Getting schedule count');
      final count = await _dao.getScheduleCount();
      _logger.i('Total schedules: $count');
      return count;
    } catch (e, stackTrace) {
      _logger.e('Failed to get schedule count', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get active schedule count
  Future<int> getActiveScheduleCount() async {
    try {
      _logger.i('Getting active schedule count');
      final count = await _dao.getActiveScheduleCount();
      _logger.i('Total active schedules: $count');
      return count;
    } catch (e, stackTrace) {
      _logger.e('Failed to get active schedule count', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Deactivate a schedule (soft delete)
  Future<bool> deactivateSchedule(String id) async {
    try {
      _logger.i('Deactivating schedule: $id');
      final result = await _dao.deactivateSchedule(id);
      _logger.i('Schedule deactivated: $id');
      return result > 0;
    } catch (e, stackTrace) {
      _logger.e('Failed to deactivate schedule', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Activate a schedule
  Future<bool> activateSchedule(String id) async {
    try {
      _logger.i('Activating schedule: $id');
      final result = await _dao.activateSchedule(id);
      _logger.i('Schedule activated: $id');
      return result > 0;
    } catch (e, stackTrace) {
      _logger.e('Failed to activate schedule', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update schedule timestamps
  Future<bool> updateScheduleTimestamps(String id) async {
    try {
      _logger.i('Updating schedule timestamps: $id');
      final result = await _dao.updateScheduleTimestamps(id);
      _logger.i('Schedule timestamps updated: $id');
      return result > 0;
    } catch (e, stackTrace) {
      _logger.e('Failed to update schedule timestamps', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Execute multiple schedule operations in a single transaction
  Future<T> executeTransaction<T>(Future<T> Function(SchedulesDao dao) action) async {
    try {
      _logger.i('Starting schedule transaction');
      final result = await action(_dao);
      _logger.i('Schedule transaction completed successfully');
      return result;
    } catch (e, stackTrace) {
      _logger.e('Schedule transaction failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Bulk insert multiple schedules
  Future<List<Schedule>> bulkInsertSchedules(List<ScheduleCompanion> schedules) async {
    try {
      _logger.i('Bulk inserting ${schedules.length} schedules');
      final insertedSchedules = await executeTransaction((dao) async {
        final results = <Schedule>[];
        for (final schedule in schedules) {
          final result = await dao.insertSchedule(schedule);
          results.add(result);
        }
        return results;
      });
      _logger.i('Bulk insert completed: ${insertedSchedules.length} schedules');
      return insertedSchedules;
    } catch (e, stackTrace) {
      _logger.e('Bulk insert failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Bulk delete multiple schedules
  Future<int> bulkDeleteSchedules(List<String> scheduleIds) async {
    try {
      _logger.i('Bulk deleting ${scheduleIds.length} schedules');
      final deletedCount = await executeTransaction((dao) async {
        var count = 0;
        for (final id in scheduleIds) {
          count += await dao.deleteSchedule(id);
        }
        return count;
      });
      _logger.i('Bulk delete completed: $deletedCount schedules');
      return deletedCount;
    } catch (e, stackTrace) {
      _logger.e('Bulk delete failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get repository statistics
  Future<Map<String, dynamic>> getRepositoryStats() async {
    try {
      _logger.i('Getting repository statistics');
      final totalSchedules = await getScheduleCount();
      final activeSchedules = await getActiveScheduleCount();
      final todaySchedules = await getTodaysSchedules().then((s) => s.length);
      
      return {
        'totalSchedules': totalSchedules,
        'activeSchedules': activeSchedules,
        'todaySchedules': todaySchedules,
        'inactiveSchedules': totalSchedules - activeSchedules,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e, stackTrace) {
      _logger.e('Failed to get repository statistics', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}