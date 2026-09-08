import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/database/schedules_dao.dart';
import 'package:titik_waktu/repositories/schedule_repository.dart';
import 'package:titik_waktu/services/alarm_service.dart';
import 'package:titik_waktu/services/storage_service.dart';

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
}

final dailySchedulesProvider = Provider<AsyncValue<List<Schedule>>>((ref) {
  final schedulesAsync = ref.watch(scheduleListProvider);
  return schedulesAsync.whenData((schedules) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return schedules.where((s) {
      if (s.startDate == null) return false;
      final scheduleDate = DateTime(s.startDate!.year, s.startDate!.month, s.startDate!.day);
      return scheduleDate.isAtSameMomentAs(today) && s.isActive;
    }).toList()..sort((a, b) => a.time.compareTo(b.time));
  });
});
