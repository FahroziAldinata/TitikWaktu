import 'package:drift/drift.dart';
import 'database.dart';

part 'schedules_dao.g.dart';

enum NotificationType {
  none,
  push,
  email,
  sms,
}

enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
}

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
}
