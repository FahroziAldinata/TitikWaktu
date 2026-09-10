import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/database/schedules_dao.dart';
import 'package:titik_waktu/providers/history_provider.dart';
import 'package:titik_waktu/repositories/history_repository.dart';

void main() {
  late AppDatabase db;
  late SchedulesDao dao;
  late HistoryRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = SchedulesDao(db);
    repository = HistoryRepository(dao);
  });

  tearDown(() async {
    await db.close();
  });

  group('History Logs Tests', () {
    test('addLog and getAllHistoryLogs should persist and order logs descending', () async {
      await repository.addLog('${HistoryLogHelper.actionScheduleCreated}: Belajar Flutter');
      await Future.delayed(const Duration(milliseconds: 10));
      await repository.addLog('${HistoryLogHelper.actionAlarmTriggered}: Belajar Flutter');
      await Future.delayed(const Duration(milliseconds: 10));
      await repository.addLog('${HistoryLogHelper.actionAlarmDismissed}: Belajar Flutter');

      final logs = await repository.getAllHistoryLogs();
      expect(logs.length, 3);
      expect(logs[0].action, startsWith('ALARM_DISMISSED'));
      expect(logs[1].action, startsWith('ALARM_TRIGGERED'));
      expect(logs[2].action, startsWith('SCHEDULE_CREATED'));
    });

    test('deleteLog should remove specific log entry', () async {
      await repository.addLog('${HistoryLogHelper.actionAlarmTriggered}: Event 1');
      await repository.addLog('${HistoryLogHelper.actionAlarmTriggered}: Event 2');

      var logs = await repository.getAllHistoryLogs();
      expect(logs.length, 2);

      final idToDelete = logs[0].id;
      await repository.deleteLog(idToDelete);

      logs = await repository.getAllHistoryLogs();
      expect(logs.length, 1);
      expect(logs[0].id, isNot(idToDelete));
    });

    test('clearAllHistory should empty the logs table', () async {
      await repository.addLog('${HistoryLogHelper.actionAlarmTriggered}: Event 1');
      await repository.addLog('${HistoryLogHelper.actionAlarmSnoozed}: Event 2');
      await repository.addLog('${HistoryLogHelper.actionAlarmDismissed}: Event 3');

      var logs = await repository.getAllHistoryLogs();
      expect(logs.length, 3);

      await repository.clearAllHistory();

      logs = await repository.getAllHistoryLogs();
      expect(logs.isEmpty, isTrue);
    });

    test('HistoryLogHelper correctly formats Indonesian action titles', () {
      expect(
        HistoryLogHelper.formatActionTitle('ALARM_TRIGGERED: Rapat'),
        'Alarm Berbunyi: Rapat',
      );
      expect(
        HistoryLogHelper.formatActionTitle('ALARM_DISMISSED: Bangun Pagi'),
        'Alarm Dimatikan: Bangun Pagi',
      );
      expect(
        HistoryLogHelper.formatActionTitle('ALARM_SNOOZED: Olahraga (5 menit)'),
        'Alarm Ditunda (Snooze): Olahraga (5 menit)',
      );
      expect(
        HistoryLogHelper.formatActionTitle('ALARM_MISSED: Minum Obat'),
        'Alarm Terlewat: Minum Obat',
      );
      expect(
        HistoryLogHelper.formatActionTitle('SCHEDULE_CREATED: Tugas'),
        'Jadwal Dibuat: Tugas',
      );
      expect(
        HistoryLogHelper.formatActionTitle('SCHEDULE_UPDATED: Tugas'),
        'Jadwal Diperbarui: Tugas',
      );
      expect(
        HistoryLogHelper.formatActionTitle('SCHEDULE_DELETED: Tugas'),
        'Jadwal Dihapus: Tugas',
      );
    });

    test('checkAndLogMissedSchedules detects past unlogged occurrences and creates ALARM_MISSED logs', () async {
      final now = DateTime(2026, 9, 10, 14, 0);

      // Schedule 1: Occurred yesterday at 08:00 (unlogged -> should be missed)
      final schedule1 = Schedule(
        id: 101,
        title: 'Minum Vitamin Pagi',
        time: DateTime(0, 0, 0, 8, 0),
        startDate: DateTime(2026, 9, 9),
        isActive: true,
        createdAt: DateTime(2026, 9, 8),
        updatedAt: DateTime(2026, 9, 8),
      );

      // Schedule 2: Occurred yesterday at 10:00 (already logged -> should NOT be duplicated)
      final schedule2 = Schedule(
        id: 102,
        title: 'Rapat Kerja',
        time: DateTime(0, 0, 0, 10, 0),
        startDate: DateTime(2026, 9, 9),
        isActive: true,
        createdAt: DateTime(2026, 9, 8),
        updatedAt: DateTime(2026, 9, 8),
      );

      // Add existing log for schedule 2 on 2026-09-09
      await repository.addLog(
        'ALARM_DISMISSED: Rapat Kerja - Schedule #102',
        timestamp: DateTime(2026, 9, 9, 10, 1),
      );

      final missedLogs = await repository.checkAndLogMissedSchedules(
        [schedule1, schedule2],
        now: now,
      );

      expect(missedLogs.length, 1);
      expect(missedLogs[0].action, contains('ALARM_MISSED'));
      expect(missedLogs[0].action, contains('Minum Vitamin Pagi'));
      expect(missedLogs[0].action, contains('Schedule #101'));

      // Check all logs in DB
      final allLogs = await repository.getAllHistoryLogs();
      expect(allLogs.length, 2); // 1 existing dismissed + 1 missed
    });
  });
}
