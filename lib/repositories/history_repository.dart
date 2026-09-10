import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/schedules_dao.dart';
import '../providers/history_provider.dart';
import '../utils/date_format_helper.dart';
import '../utils/recurrence_helper.dart';

class HistoryRepository {
  final SchedulesDao _dao;

  HistoryRepository(this._dao);

  Future<List<HistoryLog>> getAllHistoryLogs() => _dao.getAllHistoryLogs();

  Stream<List<HistoryLog>> watchAllHistoryLogs() => _dao.watchAllHistoryLogs();

  Future<int> addLog(String action, {DateTime? timestamp}) {
    return _dao.insertHistoryLog(
      HistoryLogsCompanion.insert(
        action: action,
        timestamp: Value(timestamp ?? DateTime.now()),
      ),
    );
  }

  Future<int> clearAllHistory() => _dao.clearAllHistoryLogs();

  Future<int> deleteLog(int id) => _dao.deleteHistoryLog(id);

  /// Check active schedules for any past occurrences that were not logged, and record them as ALARM_MISSED.
  Future<List<HistoryLog>> checkAndLogMissedSchedules(
    List<Schedule> schedules, {
    DateTime? now,
    Duration lookbackWindow = const Duration(hours: 48),
    Duration gracePeriod = const Duration(minutes: 10),
  }) async {
    final currentTime = now ?? DateTime.now();
    final lookbackStart = currentTime.subtract(lookbackWindow);
    final logs = await getAllHistoryLogs();
    final newMissedLogs = <HistoryLog>[];

    for (final schedule in schedules) {
      if (!schedule.isActive || schedule.startDate == null) continue;

      DateTime evalDay = DateTime(lookbackStart.year, lookbackStart.month, lookbackStart.day);
      final today = DateTime(currentTime.year, currentTime.month, currentTime.day);

      while (!evalDay.isAfter(today)) {
        final occ = RecurrenceHelper.getOccurrenceForDate(schedule, evalDay);
        if (occ != null) {
          final occTime = occ.actualDateTime;
          if (occTime.isAfter(lookbackStart) && occTime.isBefore(currentTime.subtract(gracePeriod))) {
            final dateKey = RecurrenceHelper.formatDateKey(occTime);
            final scheduleTag = 'Schedule #${schedule.id}';

            final hasExistingLog = logs.any((l) {
              final isSameSchedule = l.action.contains(scheduleTag) || l.action.contains(schedule.title);
              final isSameDay = RecurrenceHelper.formatDateKey(l.timestamp) == dateKey;
              return isSameSchedule && isSameDay;
            });

            if (!hasExistingLog) {
              final actionText =
                  '${HistoryLogHelper.actionAlarmMissed}: ${schedule.title} (${AppDateFormatter.formatTime(occTime)}, $dateKey) - $scheduleTag';
              final id = await addLog(actionText, timestamp: occTime);
              newMissedLogs.add(HistoryLog(id: id, action: actionText, timestamp: occTime));
            }
          }
        }
        evalDay = evalDay.add(const Duration(days: 1));
      }
    }
    return newMissedLogs;
  }
}
