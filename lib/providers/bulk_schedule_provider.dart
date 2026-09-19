import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:titik_waktu/repositories/schedule_repository.dart';
import 'package:titik_waktu/services/alarm_service.dart';

/// State untuk alur bulk schedule (kalender multi-select + set jam)
class BulkScheduleState {
  final Set<DateTime> selectedDates;
  final Map<DateTime, TimeOfDay?> timeMap;
  final NotificationType notificationType;
  final bool isSaving;

  const BulkScheduleState({
    this.selectedDates = const {},
    this.timeMap = const {},
    this.notificationType = NotificationType.notification,
    this.isSaving = false,
  });

  BulkScheduleState copyWith({
    Set<DateTime>? selectedDates,
    Map<DateTime, TimeOfDay?>? timeMap,
    NotificationType? notificationType,
    bool? isSaving,
  }) {
    return BulkScheduleState(
      selectedDates: selectedDates ?? this.selectedDates,
      timeMap: timeMap ?? this.timeMap,
      notificationType: notificationType ?? this.notificationType,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  /// true jika semua tanggal yang dipilih sudah punya jam
  bool get allTimesSet =>
      selectedDates.isNotEmpty &&
      selectedDates.every((d) => timeMap[d] != null);
}

class BulkScheduleNotifier extends StateNotifier<BulkScheduleState> {
  final ScheduleRepository _repository;
  final AlarmService _alarmService = AlarmService();

  BulkScheduleNotifier(this._repository) : super(const BulkScheduleState());

  /// Toggle seleksi tanggal (normalized ke date-only, no time component)
  void toggleDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final current = Set<DateTime>.from(state.selectedDates);
    final currentTimeMap = Map<DateTime, TimeOfDay?>.from(state.timeMap);

    if (current.contains(normalized)) {
      current.remove(normalized);
      currentTimeMap.remove(normalized);
    } else {
      current.add(normalized);
    }

    state = state.copyWith(
      selectedDates: current,
      timeMap: currentTimeMap,
    );
  }

  /// Set jam untuk tanggal tertentu
  void setTime(DateTime date, TimeOfDay time) {
    final normalized = DateTime(date.year, date.month, date.day);
    final currentTimeMap = Map<DateTime, TimeOfDay?>.from(state.timeMap);
    currentTimeMap[normalized] = time;
    state = state.copyWith(timeMap: currentTimeMap);
  }

  /// Ubah tipe notifikasi untuk seluruh batch
  void setNotificationType(NotificationType type) {
    state = state.copyWith(notificationType: type);
  }

  /// Tanggal terpilih diurutkan kronologis
  List<DateTime> get sortedDates {
    final dates = state.selectedDates.toList()..sort();
    return dates;
  }

  /// Simpan semua jadwal sebagai batch. Atomic — kalau satu gagal, semua batal.
  Future<List<Schedule>> saveBatch(Category category) async {
    assert(state.allTimesSet, 'Semua tanggal harus sudah punya jam sebelum saveBatch dipanggil');
    state = state.copyWith(isSaving: true);
    try {
      final companions = sortedDates.map((date) {
        final tod = state.timeMap[date]!;
        final scheduleDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          tod.hour,
          tod.minute,
        );
        return SchedulesCompanion(
          title: Value(category.name),
          time: Value(scheduleDateTime),
          startDate: Value(scheduleDateTime),
          categoryId: Value(category.id),
          isActive: const Value(true),
          recurrenceType: Value(RecurrenceType.once.value),
          notificationType: Value(state.notificationType.value),
        );
      }).toList();

      // Bulk insert dalam satu transaction — atomic
      final created = await _repository.bulkInsertSchedules(companions);

      // Schedule alarm untuk tiap jadwal yang baru dibuat
      for (final schedule in created) {
        try {
          await _alarmService.scheduleAlarm(schedule);
        } catch (e) {
          debugPrint('Warning: Alarm scheduling failed for schedule ${schedule.id}: $e');
        }
      }

      return created;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

/// Provider utama — autoDispose sehingga state bersih saat keluar dari flow
final bulkScheduleProvider =
    StateNotifierProvider.autoDispose<BulkScheduleNotifier, BulkScheduleState>(
  (ref) {
    final repo = ref.watch(scheduleRepositoryProvider);
    return BulkScheduleNotifier(repo);
  },
);

/// Provider list jadwal per kategori — dipakai di CategoryDetailScreen
final categorySchedulesProvider =
    FutureProvider.autoDispose.family<List<Schedule>, int>(
  (ref, categoryId) async {
    final repo = ref.watch(scheduleRepositoryProvider);
    return repo.getSchedulesByCategory(categoryId);
  },
);
