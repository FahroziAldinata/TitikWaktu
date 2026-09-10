import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../repositories/history_repository.dart';
import 'schedule_provider.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final dao = ref.watch(schedulesDaoProvider);
  return HistoryRepository(dao);
});

final historyLogListProvider = StreamProvider<List<HistoryLog>>((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  return repo.watchAllHistoryLogs();
});

enum HistoryActionCategory {
  all,
  alarm,
  schedule,
  snooze,
  missed,
}

class HistoryLogHelper {
  HistoryLogHelper._();

  static const String actionAlarmTriggered = 'ALARM_TRIGGERED';
  static const String actionAlarmDismissed = 'ALARM_DISMISSED';
  static const String actionAlarmSnoozed = 'ALARM_SNOOZED';
  static const String actionAlarmMissed = 'ALARM_MISSED';
  static const String actionScheduleCreated = 'SCHEDULE_CREATED';
  static const String actionScheduleUpdated = 'SCHEDULE_UPDATED';
  static const String actionScheduleDeleted = 'SCHEDULE_DELETED';

  static String formatActionTitle(String rawAction) {
    if (rawAction.startsWith('ALARM_TRIGGERED')) {
      final detail = _extractDetail(rawAction);
      return detail.isNotEmpty ? 'Alarm Berbunyi: $detail' : 'Alarm Berbunyi';
    }
    if (rawAction.startsWith('ALARM_DISMISSED')) {
      final detail = _extractDetail(rawAction);
      return detail.isNotEmpty ? 'Alarm Dimatikan: $detail' : 'Alarm Dimatikan';
    }
    if (rawAction.startsWith('ALARM_SNOOZED')) {
      final detail = _extractDetail(rawAction);
      return detail.isNotEmpty ? 'Alarm Ditunda (Snooze): $detail' : 'Alarm Ditunda (Snooze)';
    }
    if (rawAction.startsWith('ALARM_MISSED')) {
      final detail = _extractDetail(rawAction);
      return detail.isNotEmpty ? 'Alarm Terlewat: $detail' : 'Alarm Terlewat';
    }
    if (rawAction.startsWith('SCHEDULE_CREATED')) {
      final detail = _extractDetail(rawAction);
      return detail.isNotEmpty ? 'Jadwal Dibuat: $detail' : 'Jadwal Dibuat';
    }
    if (rawAction.startsWith('SCHEDULE_UPDATED')) {
      final detail = _extractDetail(rawAction);
      return detail.isNotEmpty ? 'Jadwal Diperbarui: $detail' : 'Jadwal Diperbarui';
    }
    if (rawAction.startsWith('SCHEDULE_DELETED')) {
      final detail = _extractDetail(rawAction);
      return detail.isNotEmpty ? 'Jadwal Dihapus: $detail' : 'Jadwal Dihapus';
    }
    return rawAction;
  }

  static String _extractDetail(String rawAction) {
    final idx = rawAction.indexOf(':');
    if (idx != -1 && idx < rawAction.length - 1) {
      return rawAction.substring(idx + 1).trim();
    }
    return '';
  }

  static IconData getActionIcon(String rawAction) {
    if (rawAction.startsWith('ALARM_DISMISSED')) return Icons.alarm_on_rounded;
    if (rawAction.startsWith('ALARM_SNOOZED')) return Icons.snooze_rounded;
    if (rawAction.startsWith('ALARM_MISSED')) return Icons.alarm_off_rounded;
    if (rawAction.startsWith('ALARM_TRIGGERED')) return Icons.alarm_rounded;
    if (rawAction.startsWith('SCHEDULE_CREATED')) return Icons.add_circle_outline_rounded;
    if (rawAction.startsWith('SCHEDULE_UPDATED')) return Icons.edit_calendar_rounded;
    if (rawAction.startsWith('SCHEDULE_DELETED')) return Icons.delete_outline_rounded;
    return Icons.history_rounded;
  }

  static Color getActionColor(String rawAction) {
    if (rawAction.startsWith('ALARM_DISMISSED')) return Colors.greenAccent;
    if (rawAction.startsWith('ALARM_SNOOZED')) return Colors.amber;
    if (rawAction.startsWith('ALARM_MISSED')) return Colors.redAccent;
    if (rawAction.startsWith('ALARM_TRIGGERED')) return Colors.orangeAccent;
    if (rawAction.startsWith('SCHEDULE_CREATED')) return Colors.blueAccent;
    if (rawAction.startsWith('SCHEDULE_UPDATED')) return Colors.tealAccent;
    if (rawAction.startsWith('SCHEDULE_DELETED')) return Colors.red;
    return Colors.grey;
  }
}
