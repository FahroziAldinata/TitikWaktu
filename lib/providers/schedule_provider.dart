import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rrule/rrule.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/database/schedules_dao.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/repositories/history_repository.dart';
import 'package:titik_waktu/repositories/schedule_repository.dart';
import 'package:titik_waktu/services/alarm_service.dart';
import 'package:titik_waktu/services/storage_service.dart';
import 'package:titik_waktu/utils/recurrence_helper.dart';
import 'package:titik_waktu/providers/history_provider.dart';

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
  final historyRepo = ref.watch(historyRepositoryProvider);
  return ScheduleListNotifier(repo, historyRepository: historyRepo);
});

class ScheduleListNotifier extends StateNotifier<AsyncValue<List<Schedule>>> {
  final ScheduleRepository _repository;
  final HistoryRepository? _historyRepository;
  final AlarmService _alarmService = AlarmService();
  
  ScheduleListNotifier(this._repository, {HistoryRepository? historyRepository})
      : _historyRepository = historyRepository,
        super(const AsyncValue.loading()) {
    _loadSchedules();
  }
  
  Future<void> _loadSchedules() async {
    state = const AsyncValue.loading();
    try {
      final schedules = await _repository.getAllSchedules();
      state = AsyncValue.data(schedules);

      if (_historyRepository != null) {
        _historyRepository!.checkAndLogMissedSchedules(schedules);
      }
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
      
      try {
        await _historyRepository?.addLog('SCHEDULE_CREATED: ${schedule.title}');
      } catch (_) {}
      
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
      
      try {
        await _historyRepository?.addLog('SCHEDULE_UPDATED: ${schedule.title}');
      } catch (_) {}
      
      await _loadSchedules();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  Future<void> deleteSchedule(int id) async {
    try {
      final schedules = state.valueOrNull ?? [];
      final target = schedules.cast<Schedule?>().firstWhere((s) => s?.id == id, orElse: () => null);
      final title = target?.title ?? 'ID $id';

      await _repository.deleteSchedule(id);
      
      try {
        await _alarmService.cancelAlarm(id.toString());
      } catch (e) {
        print('Warning: Alarm cancel failed: $e');
      }
      
      try {
        await _historyRepository?.addLog('SCHEDULE_DELETED: $title');
      } catch (_) {}
      
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

  /// Reload schedules from DB — call this after bulk insert from an external flow
  Future<void> reload() => _loadSchedules();

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
      schedule.time?.hour ?? 0,
      schedule.time?.minute ?? 0,
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
      ..sort((a, b) {
        if (a.time == null && b.time == null) return 0;
        if (a.time == null) return 1; // Waktu null ditaruh di akhir list
        if (b.time == null) return -1;
        return a.time!.compareTo(b.time!);
      });
  });
});

/// Cari DateTime occurrence berikutnya dari schedule setelah [after].
/// Iterate harian max 365 hari ke depan. Return null jika tidak ada atau time null.
DateTime? findNextOccurrenceAfter(Schedule schedule, DateTime after) {
  // Dikecualikan dari Hero Card jika waktu belum diatur
  if (schedule.time == null) return null;
  final time = schedule.time!;

  // Iterasi dari hari ini atau start date, cek tiap hari
  final startSearch = DateTime(after.year, after.month, after.day);

  for (int i = 0; i < 365; i++) {
    final checkDay = startSearch.add(Duration(days: i));
    if (!isScheduleOccurringOn(schedule, checkDay)) continue;

    // Occurrence terjadi di checkDay — hitung waktu tepatnya
    final occurrenceDateTime = DateTime(
      checkDay.year,
      checkDay.month,
      checkDay.day,
      time.hour,
      time.minute,
    );

    // Kalau hari pertama (hari ini), cek apakah jamnya belum lewat
    if (i == 0 && occurrenceDateTime.isBefore(after)) continue;

    return occurrenceDateTime;
  }
  return null;
}

/// Jadwal terdekat dari sekarang (lintas hari jika perlu).
/// Return null jika tidak ada jadwal mendatang sama sekali.
final nextUpcomingScheduleProvider =
    Provider<AsyncValue<({Schedule schedule, DateTime occurrenceTime})?>>((ref) {
  final schedulesAsync = ref.watch(scheduleListProvider);
  return schedulesAsync.whenData((schedules) {
    final now = DateTime.now();

    ({Schedule schedule, DateTime occurrenceTime})? nearest;

    for (final s in schedules) {
      final occ = findNextOccurrenceAfter(s, now);
      if (occ == null) continue;
      if (nearest == null || occ.isBefore(nearest.occurrenceTime)) {
        nearest = (schedule: s, occurrenceTime: occ);
      }
    }
    return nearest;
  });
});

/// Map categoryId → List<DateTime> (jadwal mendatang terdekat per kategori).
/// Digunakan untuk chip tanggal di Kelola Kategori.
final categoryUpcomingDatesProvider =
    Provider<AsyncValue<Map<int, List<DateTime>>>>((ref) {
  final schedulesAsync = ref.watch(scheduleListProvider);
  return schedulesAsync.whenData((schedules) {
    final now = DateTime.now();
    final result = <int, List<DateTime>>{};

    for (final s in schedules) {
      if (s.categoryId == null) continue;
      // Cari occurrence mendatang untuk schedule ini
      final dates = _findNextNOccurrences(s, now, n: 10);
      final catList = result.putIfAbsent(s.categoryId!, () => []);
      catList.addAll(dates);
    }

    // Per kategori: sort kronologis
    for (final key in result.keys) {
      result[key]!.sort();
    }
    return result;
  });
});

/// Cari N occurrence berikutnya dari schedule setelah [after].
List<DateTime> _findNextNOccurrences(Schedule schedule, DateTime after, {int n = 10}) {
  final results = <DateTime>[];
  final startSearch = DateTime(after.year, after.month, after.day);
  final time = schedule.time;

  for (int i = 0; i < 365 && results.length < n; i++) {
    final checkDay = startSearch.add(Duration(days: i));
    if (!isScheduleOccurringOn(schedule, checkDay)) continue;

    final occurrenceDateTime = DateTime(
      checkDay.year,
      checkDay.month,
      checkDay.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );

    if (i == 0 && time != null && occurrenceDateTime.isBefore(after)) continue;
    results.add(occurrenceDateTime);
  }
  return results;
}

