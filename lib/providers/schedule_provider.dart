import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titik_waktu/models/schedule.dart';
import 'package:titik_waktu/services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final scheduleListProvider = StateNotifierProvider<ScheduleListNotifier, AsyncValue<List<Schedule>>>((ref) {
  return ScheduleListNotifier(ref.read(storageServiceProvider));
});

class ScheduleListNotifier extends StateNotifier<AsyncValue<List<Schedule>>> {
  final StorageService _storage;
  
  ScheduleListNotifier(this._storage) : super(const AsyncValue.loading()) {
    _loadSchedules();
  }
  
  Future<void> _loadSchedules() async {
    state = const AsyncValue.loading();
    try {
      final schedules = await _storage.getAllSchedules();
      state = AsyncValue.data(schedules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> addSchedule(Schedule schedule) async {
    await _storage.insertSchedule(schedule);
    await _loadSchedules();
  }
  
  Future<void> updateSchedule(Schedule schedule) async {
    await _storage.updateSchedule(schedule);
    await _loadSchedules();
  }
  
  Future<void> deleteSchedule(String id) async {
    await _storage.deleteSchedule(id);
    await _loadSchedules();
  }
  
  Future<void> toggleSchedule(String id) async {
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
      final scheduleDate = DateTime(s.startDate.year, s.startDate.month, s.startDate.day);
      return scheduleDate.isAtSameMomentAs(today) && s.isActive;
    }).toList()..sort((a, b) => a.time.compareTo(b.time));
  });
});
