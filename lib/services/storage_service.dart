import 'package:titik_waktu/models/schedule.dart';

class StorageService {
  final List<Schedule> _schedules = [];
  
  Future<List<Schedule>> getAllSchedules() async {
    return List.from(_schedules);
  }
  
  Future<Schedule?> getScheduleById(String id) async {
    try {
      return _schedules.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
  
  Future<void> insertSchedule(Schedule schedule) async {
    _schedules.add(schedule);
  }
  
  Future<void> updateSchedule(Schedule schedule) async {
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _schedules[index] = schedule;
    }
  }
  
  Future<void> deleteSchedule(String id) async {
    _schedules.removeWhere((s) => s.id == id);
  }
  
  Future<List<Schedule>> getSchedulesByDate(DateTime date) async {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _schedules.where((s) {
      final scheduleDate = DateTime(s.startDate.year, s.startDate.month, s.startDate.day);
      return scheduleDate.isAtSameMomentAs(targetDate);
    }).toList();
  }
  
  Future<List<Schedule>> getActiveSchedules() async {
    return _schedules.where((s) => s.isActive).toList();
  }
}
