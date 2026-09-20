import 'package:flutter_test/flutter_test.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';

void main() {
  group('findNextOccurrenceAfter & Upcoming Schedule Tests', () {
    final baseDate = DateTime(2026, 9, 20, 10, 0); // Sunday 10:00

    test('findNextOccurrenceAfter returns same day if time is in future', () {
      final schedule = Schedule(
        id: 1,
        title: 'Lunch Meeting',
        time: DateTime(2026, 9, 20, 12, 30),
        startDate: DateTime(2026, 9, 20),
        recurrenceType: RecurrenceType.none.index,
        isActive: true,
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      );

      final next = findNextOccurrenceAfter(schedule, baseDate);
      expect(next, isNotNull);
      expect(next!.year, 2026);
      expect(next.month, 9);
      expect(next.day, 20);
      expect(next.hour, 12);
      expect(next.minute, 30);
    });

    test('findNextOccurrenceAfter returns null for single non-repeating schedule in the past', () {
      final schedule = Schedule(
        id: 2,
        title: 'Morning Breakfast',
        time: DateTime(2026, 9, 20, 8, 0),
        startDate: DateTime(2026, 9, 20),
        recurrenceType: RecurrenceType.none.index,
        isActive: true,
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      );

      final next = findNextOccurrenceAfter(schedule, baseDate);
      expect(next, isNull);
    });

    test('findNextOccurrenceAfter finds next day occurrence for daily repeating schedule if today passed', () {
      final schedule = Schedule(
        id: 3,
        title: 'Daily Morning Standup',
        time: DateTime(2026, 9, 1, 8, 0),
        startDate: DateTime(2026, 9, 1),
        recurrenceType: RecurrenceType.daily.index,
        recurrenceRule: 'RRULE:FREQ=DAILY',
        isActive: true,
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      );

      final next = findNextOccurrenceAfter(schedule, baseDate);
      expect(next, isNotNull);
      // Since 8:00 passed on 2026-09-20 (baseDate is 10:00), next is tomorrow 2026-09-21 08:00
      expect(next!.year, 2026);
      expect(next.month, 9);
      expect(next.day, 21);
      expect(next.hour, 8);
      expect(next.minute, 0);
    });
  });
}
