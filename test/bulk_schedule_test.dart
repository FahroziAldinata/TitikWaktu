import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/database/schedules_dao.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/providers/bulk_schedule_provider.dart';
import 'package:titik_waktu/repositories/schedule_repository.dart';

void main() {
  late AppDatabase db;
  late SchedulesDao dao;
  late ScheduleRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = SchedulesDao(db);
    repo = ScheduleRepository(dao);
  });

  tearDown(() async {
    await db.close();
  });

  group('Bulk Schedule DAO & Repository Tests', () {
    test('getSchedulesByCategory returns schedules filtered by categoryId', () async {
      final now = DateTime(2026, 9, 19, 10, 0);

      // Insert category 1 schedule
      await dao.insertSchedule(
        SchedulesCompanion.insert(
          title: 'Bola Match 1',
          time: now,
          categoryId: const Value(1),
        ),
      );

      // Insert category 2 schedule
      await dao.insertSchedule(
        SchedulesCompanion.insert(
          title: 'Work Meeting',
          time: now.add(const Duration(hours: 1)),
          categoryId: const Value(2),
        ),
      );

      // Insert another category 1 schedule
      await dao.insertSchedule(
        SchedulesCompanion.insert(
          title: 'Bola Match 2',
          time: now.add(const Duration(days: 3)),
          categoryId: const Value(1),
        ),
      );

      final cat1Schedules = await repo.getSchedulesByCategory(1);
      expect(cat1Schedules.length, equals(2));
      expect(cat1Schedules.map((s) => s.title), containsAll(['Bola Match 1', 'Bola Match 2']));

      final cat2Schedules = await repo.getSchedulesByCategory(2);
      expect(cat2Schedules.length, equals(1));
      expect(cat2Schedules.first.title, equals('Work Meeting'));

      final cat3Schedules = await repo.getSchedulesByCategory(99);
      expect(cat3Schedules, isEmpty);
    });
  });

  group('BulkScheduleNotifier State Logic Tests', () {
    test('toggleDate normalizes dates and toggles selection', () {
      final notifier = BulkScheduleNotifier(repo);

      final date1WithTime = DateTime(2026, 9, 20, 14, 30, 45);
      notifier.toggleDate(date1WithTime);

      expect(notifier.state.selectedDates.length, equals(1));
      final selected = notifier.state.selectedDates.first;
      expect(selected, equals(DateTime(2026, 9, 20))); // Normalized to 00:00:00

      // Toggle again to deselect
      notifier.toggleDate(DateTime(2026, 9, 20, 23, 59));
      expect(notifier.state.selectedDates, isEmpty);
    });

    test('setTime and allTimesSet verification', () {
      final notifier = BulkScheduleNotifier(repo);

      final day1 = DateTime(2026, 9, 21);
      final day2 = DateTime(2026, 9, 22);

      notifier.toggleDate(day1);
      notifier.toggleDate(day2);

      expect(notifier.state.allTimesSet, isFalse);

      notifier.setTime(day1, const TimeOfDay(hour: 19, minute: 0));
      expect(notifier.state.allTimesSet, isFalse);

      notifier.setTime(day2, const TimeOfDay(hour: 21, minute: 30));
      expect(notifier.state.allTimesSet, isTrue);

      expect(notifier.sortedDates, equals([day1, day2]));
    });

    test('Deselecting date also clears its configured time', () {
      final notifier = BulkScheduleNotifier(repo);

      final day1 = DateTime(2026, 9, 25);
      notifier.toggleDate(day1);
      notifier.setTime(day1, const TimeOfDay(hour: 15, minute: 0));

      expect(notifier.state.timeMap[day1], equals(const TimeOfDay(hour: 15, minute: 0)));

      // Deselect
      notifier.toggleDate(day1);
      expect(notifier.state.selectedDates, isEmpty);
      expect(notifier.state.timeMap[day1], isNull);
    });

    test('saveBatch creates atomic schedules with category title and recurrence once', () async {
      final notifier = BulkScheduleNotifier(repo);

      final day1 = DateTime(2026, 10, 1);
      final day2 = DateTime(2026, 10, 5);

      notifier.toggleDate(day1);
      notifier.toggleDate(day2);
      notifier.setTime(day1, const TimeOfDay(hour: 20, minute: 0));
      notifier.setTime(day2, const TimeOfDay(hour: 22, minute: 15));
      notifier.setNotificationType(NotificationType.fullAlarm);

      final category = Category(
        id: 7,
        name: 'Liga Inggris',
        colorHex: '#1D9E75',
      );

      final results = await notifier.saveBatch(category);

      expect(results.length, equals(2));
      expect(results[0].title, equals('Liga Inggris'));
      expect(results[0].categoryId, equals(7));
      expect(results[0].time, equals(DateTime(2026, 10, 1, 20, 0)));
      expect(results[0].recurrenceType, equals(RecurrenceType.once.value));
      expect(results[0].notificationType, equals(NotificationType.fullAlarm.value));

      expect(results[1].title, equals('Liga Inggris'));
      expect(results[1].time, equals(DateTime(2026, 10, 5, 22, 15)));

      // Verify in database
      final savedInDb = await repo.getSchedulesByCategory(7);
      expect(savedInDb.length, equals(2));
    });
  });
}
