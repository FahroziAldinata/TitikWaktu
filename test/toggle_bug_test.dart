import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/database/schedules_dao.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
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

  test('Investigate toggleSchedule: does it delete or update in DB?', () async {
    final now = DateTime(2026, 9, 19, 10, 0);

    // 1. Create a schedule
    final companion = SchedulesCompanion.insert(
      title: 'Test Alarm',
      time: now,
      startDate: Value(now),
      categoryId: const Value(1),
      isActive: const Value(true),
    );
    final id = await dao.insertSchedule(companion);
    print('Inserted schedule id: $id');

    // Verify it exists
    final initialAll = await dao.getAllSchedules();
    print('DB count before toggle: ${initialAll.length}');
    expect(initialAll.length, 1);
    expect(initialAll.first.isActive, true);

    // 2. Simulate toggleSchedule
    final schedule = initialAll.first;
    final updated = schedule.copyWith(isActive: !schedule.isActive);
    print('Updating schedule with isActive: ${updated.isActive}');

    final updateCompanion = SchedulesCompanion(
      id: Value(updated.id),
      title: Value(updated.title),
      description: Value(updated.description),
      time: Value(updated.time),
      startDate: Value(updated.startDate),
      endDate: Value(updated.endDate),
      notificationType: Value(updated.notificationType),
      soundPath: Value(updated.soundPath),
      color: Value(updated.color),
      isActive: Value(updated.isActive),
      recurrenceType: Value(updated.recurrenceType),
      recurrenceRule: Value(updated.recurrenceRule),
      interval: Value(updated.interval),
      daysOfWeek: Value(updated.daysOfWeek),
      dayOfMonth: Value(updated.dayOfMonth),
      monthPattern: Value(updated.monthPattern),
      endCount: Value(updated.endCount),
      exceptionDates: Value(updated.exceptionDates),
      rescheduledDates: Value(updated.rescheduledDates),
      categoryId: Value(updated.categoryId),
      updatedAt: Value(DateTime.now()),
    );

    await repo.updateSchedule(updateCompanion);

    // 3. Check DB directly!
    final afterToggleAll = await dao.getAllSchedules();
    print('DB count after toggle (getAllSchedules): ${afterToggleAll.length}');
    print('Row in DB: ${afterToggleAll.isNotEmpty ? "id=${afterToggleAll.first.id}, isActive=${afterToggleAll.first.isActive}" : "EMPTY!"}');

    // 4. Check category schedules
    final categorySchedules = await dao.getSchedulesByCategory(1);
    print('Category 1 count after toggle: ${categorySchedules.length}');

    // 5. Check isScheduleOccurringOn (used by dailySchedulesProvider)
    final occursOnToday = isScheduleOccurringOn(afterToggleAll.first, now);
    print('Occurs on today for dailySchedulesProvider: $occursOnToday');
  });
}
