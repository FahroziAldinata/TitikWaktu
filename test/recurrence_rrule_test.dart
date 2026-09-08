import 'package:flutter_test/flutter_test.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';

void main() {
  group('Recurrence Engine RRULE (RFC 5545) Tests', () {
    test('1. Sekali (Single occurrence) - Kuliah Pagi', () {
      final schedule = Schedule(
        id: 1,
        title: 'Kuliah Pagi (Sekali)',
        time: DateTime(0, 0, 0, 8, 0),
        startDate: DateTime(2026, 9, 8),
        recurrenceType: RecurrenceType.once.value,
        recurrenceRule: null,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 8)), isTrue);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 9)), isFalse);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 7)), isFalse);
    });

    test('2. Harian (Daily) - Minum Vitamin', () {
      final schedule = Schedule(
        id: 2,
        title: 'Minum Vitamin (Harian)',
        time: DateTime(0, 0, 0, 7, 0),
        startDate: DateTime(2026, 9, 8),
        recurrenceType: RecurrenceType.daily.value,
        recurrenceRule: 'RRULE:FREQ=DAILY;INTERVAL=1',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Before start date
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 7)), isFalse);
      // On start date
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 8)), isTrue);
      // Days after
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 9)), isTrue);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 20)), isTrue);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 10, 1)), isTrue);
    });

    test('3. Mingguan (Weekly) - Review Sprint (Senin, Rabu, Jumat)', () {
      final schedule = Schedule(
        id: 3,
        title: 'Review Sprint (Mingguan)',
        time: DateTime(0, 0, 0, 10, 0),
        startDate: DateTime(2026, 9, 7), // Monday
        recurrenceType: RecurrenceType.weekly.value,
        recurrenceRule: 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,FR',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Monday 2026-09-07 -> MO (True)
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 7)), isTrue);
      // Tuesday 2026-09-08 -> TU (False)
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 8)), isFalse);
      // Wednesday 2026-09-09 -> WE (True)
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 9)), isTrue);
      // Thursday 2026-09-10 -> TH (False)
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 10)), isFalse);
      // Friday 2026-09-11 -> FR (True)
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 11)), isTrue);
      // Saturday 2026-09-12 -> SA (False)
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 12)), isFalse);
    });

    test('4. Bulanan (Monthly) - Bayar Tagihan (Setiap tgl 15)', () {
      final schedule = Schedule(
        id: 4,
        title: 'Bayar Tagihan (Bulanan)',
        time: DateTime(0, 0, 0, 9, 0),
        startDate: DateTime(2026, 9, 15),
        recurrenceType: RecurrenceType.monthly.value,
        recurrenceRule: 'RRULE:FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=15',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // September 15 -> True
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 15)), isTrue);
      // September 16 -> False
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 16)), isFalse);
      // October 15 -> True
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 10, 15)), isTrue);
      // November 15 -> True
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 11, 15)), isTrue);
    });

    test('5. Exception Dates - Skip tanggal tertentu', () {
      final schedule = Schedule(
        id: 5,
        title: 'Olahraga Harian (Skip Libur)',
        time: DateTime(0, 0, 0, 6, 0),
        startDate: DateTime(2026, 9, 8),
        recurrenceType: RecurrenceType.daily.value,
        recurrenceRule: 'RRULE:FREQ=DAILY;INTERVAL=1',
        exceptionDates: '2026-09-10, 2026-09-12',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 8)), isTrue);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 9)), isTrue);
      // Exception dates must be skipped
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 10)), isFalse);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 11)), isTrue);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 12)), isFalse);
    });

    test('6. Inactive Schedule - Toggle off', () {
      final schedule = Schedule(
        id: 6,
        title: 'Jadwal Nonaktif',
        time: DateTime(0, 0, 0, 8, 0),
        startDate: DateTime(2026, 9, 8),
        recurrenceType: RecurrenceType.daily.value,
        recurrenceRule: 'RRULE:FREQ=DAILY;INTERVAL=1',
        isActive: false, // Inactive
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 8)), isFalse);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 9)), isFalse);
    });
  });
}
