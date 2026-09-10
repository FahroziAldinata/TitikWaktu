import 'package:flutter_test/flutter_test.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/utils/recurrence_helper.dart';

void main() {
  group('Monthly View Calendar Engine Tests', () {
    test('isScheduleOccurringOn accurately detects single occurrence date', () {
      final schedule = Schedule(
        id: 1,
        title: 'Interview',
        time: DateTime(0, 0, 0, 10, 0),
        startDate: DateTime(2026, 9, 15),
        recurrenceType: RecurrenceType.once.value,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(RecurrenceHelper.isScheduleOccurringOn(schedule, DateTime(2026, 9, 15)), isTrue);
      expect(RecurrenceHelper.isScheduleOccurringOn(schedule, DateTime(2026, 9, 14)), isFalse);
      expect(RecurrenceHelper.isScheduleOccurringOn(schedule, DateTime(2026, 9, 16)), isFalse);
    });

    test('isScheduleOccurringOn accurately detects weekly recurrence', () {
      // Every 2 weeks on Monday and Wednesday starting Sept 7, 2026 (Monday)
      final rrule = 'RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE';
      final schedule = Schedule(
        id: 2,
        title: 'Gym Session',
        time: DateTime(0, 0, 0, 7, 0),
        startDate: DateTime(2026, 9, 7),
        recurrenceType: RecurrenceType.weekly.value,
        recurrenceRule: rrule,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Sept 7 (Mon, week 1): Yes
      expect(RecurrenceHelper.isScheduleOccurringOn(schedule, DateTime(2026, 9, 7)), isTrue);
      // Sept 9 (Wed, week 1): Yes
      expect(RecurrenceHelper.isScheduleOccurringOn(schedule, DateTime(2026, 9, 9)), isTrue);
      // Sept 14 (Mon, week 2 - skipped interval): No
      expect(RecurrenceHelper.isScheduleOccurringOn(schedule, DateTime(2026, 9, 14)), isFalse);
      // Sept 21 (Mon, week 3): Yes
      expect(RecurrenceHelper.isScheduleOccurringOn(schedule, DateTime(2026, 9, 21)), isTrue);
    });

    test('isScheduleOccurringOn respects exceptionDates and rescheduledDates in monthly calendar', () {
      final schedule = Schedule(
        id: 3,
        title: 'Daily Standup',
        time: DateTime(0, 0, 0, 9, 0),
        startDate: DateTime(2026, 9, 1),
        recurrenceType: RecurrenceType.daily.value,
        recurrenceRule: 'RRULE:FREQ=DAILY;INTERVAL=1',
        exceptionDates: '2026-09-10',
        rescheduledDates: '{"2026-09-11":"2026-09-12T15:00:00.000"}',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Sept 10 is skipped via exceptionDates
      expect(RecurrenceHelper.isScheduleOccurringOn(schedule, DateTime(2026, 9, 10)), isFalse);

      // Sept 11 is rescheduled to Sept 12 -> on Sept 11 it does NOT occur
      expect(RecurrenceHelper.isScheduleOccurringOn(schedule, DateTime(2026, 9, 11)), isFalse);

      // Sept 12 has the normal daily occurrence + the rescheduled occurrence
      expect(RecurrenceHelper.isScheduleOccurringOn(schedule, DateTime(2026, 9, 12)), isTrue);
      final occ = RecurrenceHelper.getOccurrenceForDate(schedule, DateTime(2026, 9, 12));
      expect(occ, isNotNull);
    });
  });
}
