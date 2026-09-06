import 'package:drift/drift.dart';
import 'database.dart';
import '../models/schedule_enums.dart';

part 'schedules_dao.g.dart';

@DriftAccessor(tables: [Schedules, HistoryLogs])
class SchedulesDao extends DatabaseAccessor<AppDatabase> with _$SchedulesDaoMixin {
  SchedulesDao(AppDatabase db) : super(db);

  Future<List<Schedule>> getAllSchedules() => select(schedules).get();
  Future<int> insertSchedule(Insertable<Schedule> schedule) => into(schedules).insert(schedule);
  Future<bool> updateSchedule(Insertable<Schedule> schedule) => update(schedules).replace(schedule);
  Future<int> deleteSchedule(Insertable<Schedule> schedule) => delete(schedules).delete(schedule);

  /// Get schedule by ID
  Future<Schedule?> getScheduleById(int id) async {
    final query = select(schedules)..where((tbl) => tbl.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Create a new schedule entry
  Future<int> createSchedule({
    required String title,
    required DateTime time,
  }) async {
    return into(schedules).insert(
      SchedulesCompanion.insert(
        title: title,
        time: time,
      ),
    );
  }

  /// Filter schedules by title keyword
  Future<List<Schedule>> searchSchedules(String query) async {
    final statement = select(schedules)..where((tbl) => tbl.title.contains(query));
    return statement.get();
  }

  /// Get upcoming schedules from now onwards
  Future<List<Schedule>> getUpcomingSchedules() async {
    final now = DateTime.now();
    final statement = select(schedules)..where((tbl) => tbl.time.isBiggerOrEqualValue(now));
    return statement.get();
  }

  /// Clear all schedule entries
  Future<int> clearAllSchedules() async {
    return delete(schedules).go();
  }

  /// Insert schedule with notification configuration
  Future<int> insertScheduleWithNotification({
    required String title,
    required DateTime time,
    required NotificationType notificationType,
  }) async {
    return customInsert(
      'INSERT INTO schedules (title, time, notification_type) VALUES (?, ?, ?)',
      variables: [
        Variable.withString(title),
        Variable.withDateTime(time),
        Variable.withInt(notificationType.index),
      ],
    );
  }

  /// Insert schedule with recurrence configuration
  Future<int> insertScheduleWithRecurrence({
    required String title,
    required DateTime time,
    required RecurrenceType recurrenceType,
  }) async {
    return customInsert(
      'INSERT INTO schedules (title, time, recurrence_type) VALUES (?, ?, ?)',
      variables: [
        Variable.withString(title),
        Variable.withDateTime(time),
        Variable.withInt(recurrenceType.index),
      ],
    );
  }

  /// Update notification type by schedule ID
  Future<int> updateNotificationType({
    required int id,
    required NotificationType notificationType,
  }) async {
    return customUpdate(
      'UPDATE schedules SET notification_type = ? WHERE id = ?',
      variables: [
        Variable.withInt(notificationType.index),
        Variable.withInt(id),
      ],
    );
  }

  /// Update recurrence type by schedule ID
  Future<int> updateRecurrenceType({
    required int id,
    required RecurrenceType recurrenceType,
  }) async {
    return customUpdate(
      'UPDATE schedules SET recurrence_type = ? WHERE id = ?',
      variables: [
        Variable.withInt(recurrenceType.index),
        Variable.withInt(id),
      ],
    );
  }

  /// Get active schedules only
  Future<List<Schedule>> getActiveSchedules() async {
    final statement = select(schedules)..where((tbl) => tbl.isActive.equals(true));
    return statement.get();
  }

  /// Get schedules for a specific date
  Future<List<Schedule>> getSchedulesByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final statement = select(schedules)
      ..where((tbl) => tbl.time.isBetween(
        Expression.literal(startOfDay),
        Expression.literal(endOfDay),
      ));
    return statement.get();
  }

  /// Get schedules for a date range
  Future<List<Schedule>> getSchedulesByDateRange(DateTime startDate, DateTime endDate) async {
    final statement = select(schedules)
      ..where((tbl) => tbl.time.isBetween(
        Expression.literal(startDate),
        Expression.literal(endDate),
      ));
    return statement.get();
  }

  /// Get schedules by notification type
  Future<List<Schedule>> getSchedulesByNotificationType(NotificationType type) async {
    final statement = select(schedules)
      ..where((tbl) => tbl.notificationType.equals(type.value));
    return statement.get();
  }

  /// Get schedules by recurrence type
  Future<List<Schedule>> getSchedulesByRecurrenceType(RecurrenceType type) async {
    final statement = select(schedules)
      ..where((tbl) => tbl.recurrenceType.equals(type.value));
    return statement.get();
  }

  /// Get schedules for today
  Future<List<Schedule>> getTodaysSchedules() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return getSchedulesByDate(today);
  }

  /// Get schedules for this week
  Future<List<Schedule>> getThisWeeksSchedules() async {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
    final endOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 7);
    
    final statement = select(schedules)
      ..where((tbl) => tbl.time.isBetween(
        Expression.literal(startOfWeek),
        Expression.literal(endOfWeek),
      ));
    return statement.get();
  }

  /// Get schedules for this month
  Future<List<Schedule>> getThisMonthsSchedules() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    final statement = select(schedules)
      ..where((tbl) => tbl.time.isBetween(
        Expression.literal(startOfMonth),
        Expression.literal(endOfMonth),
      ));
    return statement.get();
  }

  /// Check if a schedule exists by ID
  Future<bool> scheduleExists(String id) async {
    try {
      final schedule = await getScheduleById(int.parse(id));
      return schedule != null;
    } catch (e) {
      return false;
    }
  }

  /// Get schedule count
  Future<int> getScheduleCount() async {
    final result = await customSelect('SELECT COUNT(*) as count FROM schedules').get();
    return result.first.read<int>('count');
  }

  /// Get active schedule count
  Future<int> getActiveScheduleCount() async {
    final result = await customSelect('SELECT COUNT(*) as count FROM schedules WHERE is_active = 1').get();
    return result.first.read<int>('count');
  }

  /// Deactivate a schedule (soft delete)
  Future<int> deactivateSchedule(String id) async {
    return customUpdate(
      'UPDATE schedules SET is_active = 0 WHERE id = ?',
      variables: [Variable.withInt(int.parse(id))],
    );
  }

  /// Activate a schedule
  Future<int> activateSchedule(String id) async {
    return customUpdate(
      'UPDATE schedules SET is_active = 1 WHERE id = ?',
      variables: [Variable.withInt(int.parse(id))],
    );
  }

  /// Update schedule timestamps
  Future<int> updateScheduleTimestamps(String id) async {
    final now = DateTime.now();
    return customUpdate(
      'UPDATE schedules SET updated_at = ? WHERE id = ?',
      variables: [
        Variable.withDateTime(now),
        Variable.withInt(int.parse(id)),
      ],
    );
  }
}
