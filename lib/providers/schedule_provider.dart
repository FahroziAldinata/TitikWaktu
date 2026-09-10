import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rrule/rrule.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/database/schedules_dao.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/repositories/schedule_repository.dart';
import 'package:titik_waktu/services/alarm_service.dart';
import 'package:titik_waktu/services/storage_service.dart';
import 'package:titik_waktu/utils/recurrence_helper.dart';

/// Database singleton provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// SchedulesDao provider
final schedulesDaoProvider = Provider<SchedulesDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.schedulesDao;
});

/// ScheduleRepository provider
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final dao = ref.watch(schedulesDaoProvider);
  return ScheduleRepository(dao);
});

/// Deprecated mock storage service provider (kept temporarily for backwards compatibility)
@Deprecated('Use scheduleRepositoryProvider instead')
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Main schedule list notifier provider
final scheduleListProvider = StateNotifierProvider<ScheduleListNotifier, AsyncValue<List<Schedule>>>((ref) {
  final repo = ref.watch(scheduleRepositoryProvider);
  return ScheduleListNotifier(repo);
});

class ScheduleListNotifier extends StateNotifier<AsyncValue<List<Schedule>>> {
  final ScheduleRepository _repository;
  final AlarmService _alarmService = AlarmService();
  
  ScheduleListNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadSchedules();
  }
  
  Future<void> _loadSchedules() async {
    state = const AsyncValue.loading();
    try {
      final schedules = await _repository.getAllSchedules();
      state = AsyncValue.data(schedules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> addSchedule(Schedule schedule) async {
    try {
      final companion = SchedulesCompanion(
        title: Value(schedule.title),
        description: Value(schedule.description),
        time: Value(schedule.time),
        startDate: Value(schedule.startDate),
        endDate: Value(schedule.endDate),
        notificationType: Value(schedule.notificationType),
        soundPath: Value(schedule.soundPath),
        color: Value(schedule.color),
        isActive: Value(schedule.isActive),
        recurrenceType: Value(schedule.recurrenceType),
        recurrenceRule: Value(schedule.recurrenceRule),
        interval: Value(schedule.interval),
        daysOfWeek: Value(schedule.daysOfWeek),
        dayOfMonth: Value(schedule.dayOfMonth),
        monthPattern: Value(schedule.monthPattern),
        endCount: Value(schedule.endCount),
        exceptionDates: Value(schedule.exceptionDates),
        rescheduledDates: Value(schedule.rescheduledDates),
        categoryId: Value(schedule.categoryId),
      );
      
      final createdSchedule = await _repository.createSchedule(companion);
      
      try {
        await _alarmService.scheduleAlarm(createdSchedule);
      } catch (e) {
        // Safe error handling so alarm failure doesn't block DB persistence
        print('Warning: Alarm scheduling failed on create: $e');
      }
      
      await _loadSchedules();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  Future<void> updateSchedule(Schedule schedule) async {
    try {
      final companion = SchedulesCompanion(
        id: Value(schedule.id),
        title: Value(schedule.title),
        description: Value(schedule.description),
        time: Value(schedule.time),
        startDate: Value(schedule.startDate),
        endDate: Value(schedule.endDate),
        notificationType: Value(schedule.notificationType),
        soundPath: Value(schedule.soundPath),
        color: Value(schedule.color),
        isActive: Value(schedule.isActive),
        recurrenceType: Value(schedule.recurrenceType),
        recurrenceRule: Value(schedule.recurrenceRule),
        interval: Value(schedule.interval),
        daysOfWeek: Value(schedule.daysOfWeek),
        dayOfMonth: Value(schedule.dayOfMonth),
        monthPattern: Value(schedule.monthPattern),
        endCount: Value(schedule.endCount),
        exceptionDates: Value(schedule.exceptionDates),
        rescheduledDates: Value(schedule.rescheduledDates),
        categoryId: Value(schedule.categoryId),
        updatedAt: Value(DateTime.now()),
      );
      
      final updatedSchedule = await _repository.updateSchedule(companion);
      
      try {
        if (updatedSchedule.isActive) {
          await _alarmService.scheduleAlarm(updatedSchedule);
        } else {
          await _alarmService.cancelAlarm(updatedSchedule.id.toString());
        }
      } catch (e) {
        print('Warning: Alarm update failed: $e');
      }
      
      await _loadSchedules();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  Future<void> deleteSchedule(int id) async {
    try {
      await _repository.deleteSchedule(id);
      
      try {
        await _alarmService.cancelAlarm(id.toString());
      } catch (e) {
        print('Warning: Alarm cancel failed: $e');
      }
      
      await _loadSchedules();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  Future<void> toggleSchedule(int id) async {
    final schedules = state.valueOrNull ?? [];
    final schedule = schedules.firstWhere((s) => s.id == id);
    final updated = schedule.copyWith(isActive: !schedule.isActive);
    await updateSchedule(updated);
  }

  Future<void> addExceptionDate(int scheduleId, DateTime date) async {
    final schedules = state.valueOrNull ?? [];
    final schedule = schedules.firstWhere((s) => s.id == scheduleId);
    final updatedExceptions = RecurrenceHelper.addExceptionDate(schedule.exceptionDates, date);
    final updated = schedule.copyWith(exceptionDates: Value(updatedExceptions));
    await updateSchedule(updated);
  }

  Future<void> removeExceptionDate(int scheduleId, String dateKey) async {
    final schedules = state.valueOrNull ?? [];
    final schedule = schedules.firstWhere((s) => s.id == scheduleId);
    final updatedExceptions = RecurrenceHelper.removeExceptionDate(schedule.exceptionDates, dateKey);
    final updated = schedule.copyWith(exceptionDates: Value(updatedExceptions));
    await updateSchedule(updated);
  }

  Future<void> rescheduleSingleOccurrence(
    int scheduleId, {
    required DateTime originalDate,
    required DateTime newDateTime,
  }) async {
    final schedules = state.valueOrNull ?? [];
    final schedule = schedules.firstWhere((s) => s.id == scheduleId);
    final updatedRescheduled = RecurrenceHelper.addRescheduledOccurrence(
      schedule.rescheduledDates,
      originalDate: originalDate,
      newDateTime: newDateTime,
    );
    final updated = schedule.copyWith(rescheduledDates: Value(updatedRescheduled));
    await updateSchedule(updated);
  }

  Future<void> resetOccurrence(int scheduleId, DateTime originalDate) async {
    final schedules = state.valueOrNull ?? [];
    final schedule = schedules.firstWhere((s) => s.id == scheduleId);
    final origKey = RecurrenceHelper.formatDateKey(originalDate);
    final updatedRescheduled = RecurrenceHelper.removeRescheduledOccurrence(schedule.rescheduledDates, origKey);
    final updated = schedule.copyWith(rescheduledDates: Value(updatedRescheduled));
    await updateSchedule(updated);
  }
}

bool isScheduleOccurringOn(Schedule schedule, DateTime date) {
  if (!schedule.isActive) return false;
  if (schedule.startDate == null) return false;

  final startDay = DateTime(
    schedule.startDate!.year,
    schedule.startDate!.month,
    schedule.startDate!.day,
  );
  final targetDay = DateTime(date.year, date.month, date.day);
  final targetKey = RecurrenceHelper.formatDateKey(targetDay);

  // Check exception dates: if targetDay itself is in exceptionDates, it MUST NOT occur (Exception always wins)
  final exceptionSet = RecurrenceHelper.parseExceptionDates(schedule.exceptionDates);
  if (exceptionSet.contains(targetKey)) {
    return false;
  }

  // 1. Check if an occurrence was rescheduled TO targetDay
  final rescheduledMap = RecurrenceHelper.parseRescheduledDates(schedule.rescheduledDates);
  for (final entry in rescheduledMap.entries) {
    final origKey = entry.key;
    final reschedDate = entry.value;

    // If the original date of this rescheduled occurrence is also an exception, skip it
    if (exceptionSet.contains(origKey)) {
      continue;
    }

    if (reschedDate.year == targetDay.year &&
        reschedDate.month == targetDay.month &&
        reschedDate.day == targetDay.day) {
      return true;
    }
  }

  // 2. Check if original occurrence on targetDay was moved AWAY to another date
  if (rescheduledMap.containsKey(targetKey)) {
    final movedTo = rescheduledMap[targetKey]!;
    if (movedTo.year != targetDay.year ||
        movedTo.month != targetDay.month ||
        movedTo.day != targetDay.day) {
      return false; // Occurrence moved away from targetDay
    }
  }

  // 4. Check boundaries
  if (targetDay.isBefore(startDay)) return false;

  if (schedule.endDate != null) {
    final endDay = DateTime(
      schedule.endDate!.year,
      schedule.endDate!.month,
      schedule.endDate!.day,
    );
    if (targetDay.isAfter(endDay)) return false;
  }

  // 5. If no RRULE string is present, evaluate as single occurrence or legacy fallback
  if (schedule.recurrenceRule == null ||
      schedule.recurrenceRule!.trim().isEmpty) {
    final recurrence = RecurrenceType.fromValue(schedule.recurrenceType);
    if (recurrence == RecurrenceType.once || recurrence == RecurrenceType.none) {
      return targetDay.isAtSameMomentAs(startDay);
    }
    if (recurrence == RecurrenceType.daily) return true;
    if (recurrence == RecurrenceType.weekly) {
      if (schedule.daysOfWeek != null && schedule.daysOfWeek! > 0) {
        final dayMask = 1 << (targetDay.weekday - 1);
        return (schedule.daysOfWeek! & dayMask) != 0;
      }
      return targetDay.weekday == startDay.weekday;
    }
    if (recurrence == RecurrenceType.monthly) {
      final targetDayOfMonth = schedule.dayOfMonth ?? startDay.day;
      return targetDay.day == targetDayOfMonth;
    }
    return targetDay.isAtSameMomentAs(startDay);
  }

  try {
    final rrule = RecurrenceRule.fromString(schedule.recurrenceRule!);
    final startUtc = DateTime.utc(
      schedule.startDate!.year,
      schedule.startDate!.month,
      schedule.startDate!.day,
      schedule.time.hour,
      schedule.time.minute,
    );

    final targetStartUtc = DateTime.utc(
      targetDay.year,
      targetDay.month,
      targetDay.day,
      0,
      0,
      0,
    );
    final targetEndUtc = DateTime.utc(
      targetDay.year,
      targetDay.month,
      targetDay.day,
      23,
      59,
      59,
    );

    final afterDate = targetStartUtc.isBefore(startUtc) ? startUtc : targetStartUtc;
    final instances = rrule.getInstances(
      start: startUtc,
      after: afterDate,
      before: targetEndUtc,
      includeAfter: true,
      includeBefore: true,
    );

    return instances.any((instance) =>
        instance.year == targetDay.year &&
        instance.month == targetDay.month &&
        instance.day == targetDay.day);
  } catch (e) {
    print('Error evaluating RRULE for schedule #${schedule.id}: $e');
    return targetDay.isAtSameMomentAs(startDay);
  }
}

final dailySchedulesProvider = Provider<AsyncValue<List<Schedule>>>((ref) {
  final schedulesAsync = ref.watch(scheduleListProvider);
  return schedulesAsync.whenData((schedules) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return schedules
        .where((s) => isScheduleOccurringOn(s, today))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  });
});


