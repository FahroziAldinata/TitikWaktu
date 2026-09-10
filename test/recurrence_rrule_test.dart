import 'package:flutter_test/flutter_test.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:titik_waktu/utils/recurrence_helper.dart';

void main() {
  group('Recurrence Engine RRULE (RFC 5545) & Phase 2 Tests', () {
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

      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 7)), isFalse);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 8)), isTrue);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 9)), isTrue);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 20)), isTrue);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 10, 1)), isTrue);
    });

    test('3. Custom Interval Harian (Setiap 3 hari)', () {
      final schedule = Schedule(
        id: 3,
        title: 'Ganti Filter Air (Tiap 3 Hari)',
        time: DateTime(0, 0, 0, 8, 0),
        startDate: DateTime(2026, 9, 1),
        recurrenceType: RecurrenceType.daily.value,
        recurrenceRule: 'RRULE:FREQ=DAILY;INTERVAL=3',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 2026-09-01 (Day 1) -> True
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 1)), isTrue);
      // 2026-09-02 (Day 2) -> False
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 2)), isFalse);
      // 2026-09-03 (Day 3) -> False
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 3)), isFalse);
      // 2026-09-04 (Day 4) -> True (+3 days)
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 4)), isTrue);
      // 2026-09-07 (Day 7) -> True (+3 days)
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 7)), isTrue);
    });

    test('4. Custom Interval Mingguan (Setiap 2 minggu: Senin & Rabu)', () {
      final schedule = Schedule(
        id: 4,
        title: 'Sprint Planning (2 Minggu Sekali)',
        time: DateTime(0, 0, 0, 10, 0),
        startDate: DateTime(2026, 9, 7), // Monday (Week 1)
        recurrenceType: RecurrenceType.weekly.value,
        recurrenceRule: 'RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Week 1
      // Mon 2026-09-07 -> True
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 7)), isTrue);
      // Tue 2026-09-08 -> False
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 8)), isFalse);
      // Wed 2026-09-09 -> True
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 9)), isTrue);
      // Thu 2026-09-10 -> False
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 10)), isFalse);

      // Week 2 (Skipped because interval=2)
      // Mon 2026-09-14 -> False
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 14)), isFalse);
      // Wed 2026-09-16 -> False
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 16)), isFalse);

      // Week 3 (Next cycle)
      // Mon 2026-09-21 -> True
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 21)), isTrue);
      // Wed 2026-09-23 -> True
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 23)), isTrue);
    });

    test('5. Bulanan (Monthly) - Bayar Tagihan (Setiap tgl 15)', () {
      final schedule = Schedule(
        id: 5,
        title: 'Bayar Tagihan (Bulanan)',
        time: DateTime(0, 0, 0, 9, 0),
        startDate: DateTime(2026, 9, 15),
        recurrenceType: RecurrenceType.monthly.value,
        recurrenceRule: 'RRULE:FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=15',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 15)), isTrue);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 16)), isFalse);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 10, 15)), isTrue);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 11, 15)), isTrue);
    });

    test('6. Bulanan Pola Hari ke-N (Senin Pertama Tiap Bulan)', () {
      final schedule = Schedule(
        id: 6,
        title: 'Townhall Bulanan (Senin Pertama)',
        time: DateTime(0, 0, 0, 9, 0),
        startDate: DateTime(2026, 9, 1),
        recurrenceType: RecurrenceType.monthly.value,
        recurrenceRule: 'RRULE:FREQ=MONTHLY;INTERVAL=1;BYDAY=1MO',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Sept 2026: 1st Monday is Sept 7
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 7)), isTrue);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 14)), isFalse);

      // Oct 2026: 1st Monday is Oct 5
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 10, 5)), isTrue);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 10, 12)), isFalse);

      // Nov 2026: 1st Monday is Nov 2
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 11, 2)), isTrue);
    });

    test('7. Exception Dates - Skip tanggal tertentu', () {
      final schedule = Schedule(
        id: 7,
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
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 13)), isTrue);
    });

    test('8. Reschedule Single Occurrence ("Edit this occurrence only")', () {
      // Harian mulai 2026-09-08
      // Jadwal tanggal 2026-09-10 dipindah ke 2026-09-10 pukul 14:00 atau dipindah ke 2026-09-11
      final schedule = Schedule(
        id: 8,
        title: 'Daily Standup',
        time: DateTime(0, 0, 0, 9, 0),
        startDate: DateTime(2026, 9, 8),
        recurrenceType: RecurrenceType.daily.value,
        recurrenceRule: 'RRULE:FREQ=DAILY;INTERVAL=1',
        // Reschedule 2026-09-10 to 2026-09-14 15:30
        rescheduledDates: '{"2026-09-10":"2026-09-14T15:30:00.000"}',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Original 2026-09-08 and 2026-09-09 still happen normally
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 8)), isTrue);
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 9)), isTrue);

      // Original 2026-09-10 was moved away -> should NOT occur on 2026-09-10
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 10)), isFalse);

      // Normal recurring 2026-09-11 still occurs
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 11)), isTrue);

      // Rescheduled date 2026-09-14 occurs!
      expect(isScheduleOccurringOn(schedule, DateTime(2026, 9, 14)), isTrue);
    });

    test('9. Upcoming occurrences generator correctly marks rescheduled instances', () {
      final schedule = Schedule(
        id: 9,
        title: 'Meeting Mingguan',
        time: DateTime(0, 0, 0, 10, 0),
        startDate: DateTime(2026, 9, 8),
        recurrenceType: RecurrenceType.daily.value,
        recurrenceRule: 'RRULE:FREQ=DAILY;INTERVAL=1',
        exceptionDates: '2026-09-09',
        rescheduledDates: '{"2026-09-10":"2026-09-10T16:00:00.000"}',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final occurrences = RecurrenceHelper.getUpcomingOccurrences(
        schedule,
        limit: 5,
        fromDate: DateTime(2026, 9, 8),
      );

      // 2026-09-08: normal
      expect(occurrences[0].originalDate, DateTime(2026, 9, 8));
      expect(occurrences[0].isRescheduled, isFalse);

      // 2026-09-09 is in exceptionDates -> skipped!

      // 2026-09-10: rescheduled time
      expect(occurrences[1].originalDate, DateTime(2026, 9, 10));
      expect(occurrences[1].isRescheduled, isTrue);
      expect(occurrences[1].actualDateTime.hour, 16);

      // 2026-09-11: normal
      expect(occurrences[2].originalDate, DateTime(2026, 9, 11));
      expect(occurrences[2].isRescheduled, isFalse);
    });

    test('10. Human-Readable Indonesian Recurrence Formatting', () {
      // Daily
      expect(
        RecurrenceHelper.formatHumanReadable(
          recurrenceType: RecurrenceType.daily,
          rruleString: 'RRULE:FREQ=DAILY;INTERVAL=1',
        ),
        'Setiap hari',
      );
      expect(
        RecurrenceHelper.formatHumanReadable(
          recurrenceType: RecurrenceType.daily,
          rruleString: 'RRULE:FREQ=DAILY;INTERVAL=3',
        ),
        'Setiap 3 hari',
      );

      // Weekly
      expect(
        RecurrenceHelper.formatHumanReadable(
          recurrenceType: RecurrenceType.weekly,
          rruleString: 'RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE',
        ),
        'Setiap 2 minggu pada Senin, Rabu',
      );

      // Monthly
      expect(
        RecurrenceHelper.formatHumanReadable(
          recurrenceType: RecurrenceType.monthly,
          rruleString: 'RRULE:FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=15',
        ),
        'Setiap bulan pada tanggal 15',
      );

      expect(
        RecurrenceHelper.formatHumanReadable(
          recurrenceType: RecurrenceType.monthly,
          rruleString: 'RRULE:FREQ=MONTHLY;INTERVAL=1;BYDAY=1MO',
        ),
        'Setiap bulan pada Senin pertama',
      );
    });

    test('11. Edge Case: Konflik Tanggal Sama di exceptionDates & rescheduledDates (exceptionDates Menang)', () {
      // Skenario:
      // Jadwal harian mulai 2026-09-08.
      // 2026-09-10 di-reschedule ke 2026-09-14 15:00.
      // Namun 2026-09-10 juga dimasukkan ke exceptionDates (misal user kemudian memilih skip).
      final scheduleA = Schedule(
        id: 11,
        title: 'Konflik Reschedule & Exception (Original Date in Exception)',
        time: DateTime(0, 0, 0, 9, 0),
        startDate: DateTime(2026, 9, 8),
        recurrenceType: RecurrenceType.daily.value,
        recurrenceRule: 'RRULE:FREQ=DAILY;INTERVAL=1',
        exceptionDates: '2026-09-10', // 2026-09-10 di-skip
        rescheduledDates: '{"2026-09-10":"2026-09-14T15:00:00.000"}', // tapi ada reschedule entry
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Tanggal 2026-09-08 & 2026-09-09 normal
      expect(isScheduleOccurringOn(scheduleA, DateTime(2026, 9, 8)), isTrue);
      expect(isScheduleOccurringOn(scheduleA, DateTime(2026, 9, 9)), isTrue);

      // Tanggal 2026-09-10 di-skip karena ada di exceptionDates (exceptionDates menang)
      expect(isScheduleOccurringOn(scheduleA, DateTime(2026, 9, 10)), isFalse);

      // Tanggal target reschedule 2026-09-14 tidak boleh dipicu karena asalnya dari 2026-09-10 yang di-skip
      // (kecuali jika 2026-09-14 sendiri adalah tanggal harian normal yang aktif)
      // Mari verifikasi dengan generator kemunculan (upcoming occurrences):
      final occurrencesA = RecurrenceHelper.getUpcomingOccurrences(
        scheduleA,
        limit: 5,
        fromDate: DateTime(2026, 9, 8),
      );

      // Pastikan tanggal 2026-09-10 tidak muncul di daftar occurrence
      expect(occurrencesA.any((o) => o.originalDate == DateTime(2026, 9, 10)), isFalse);

      // Skenario B: Tanggal target reschedule (2026-09-14) dimasukkan ke exceptionDates
      final scheduleB = Schedule(
        id: 12,
        title: 'Konflik Reschedule & Exception (Target Date in Exception)',
        time: DateTime(0, 0, 0, 9, 0),
        startDate: DateTime(2026, 9, 8),
        recurrenceType: RecurrenceType.weekly.value, // Mingguan Senin saja
        recurrenceRule: 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO',
        exceptionDates: '2026-09-11', // Jumat 2026-09-11 di-skip
        rescheduledDates: '{"2026-09-07":"2026-09-11T14:00:00.000"}', // Senin 7 Sept dipindah ke Jumat 11 Sept
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Pada Jumat 2026-09-11, jadwal di-skip karena 2026-09-11 ada di exceptionDates (exceptionDates menang)
      expect(isScheduleOccurringOn(scheduleB, DateTime(2026, 9, 11)), isFalse);

      // Tanggal Senin 2026-09-14 (minggu berikutnya) tetap berjalan normal
      expect(isScheduleOccurringOn(scheduleB, DateTime(2026, 9, 14)), isTrue);
    });
  });
}
