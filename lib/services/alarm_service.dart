import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/services/permission_service.dart';
import 'package:timezone/timezone.dart' as tz;

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final PermissionService _permissionService = PermissionService();

  Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  Future<bool> scheduleAlarm(Schedule schedule) async {
    if (!schedule.isActive) return false;

    final hasPermissions = await _checkRequiredPermissions(schedule);
    if (!hasPermissions) return false;

    final scheduledTime = DateTime(
      schedule.startDate!.year,
      schedule.startDate!.month,
      schedule.startDate!.day,
      schedule.time.hour,
      schedule.time.minute,
    );

    if (scheduledTime.isBefore(DateTime.now())) return false;

    if (schedule.notificationType == NotificationType.fullAlarm) {
      await _scheduleFullAlarm(schedule, scheduledTime);
    } else {
      await _scheduleNotification(schedule, scheduledTime);
    }

    return true;
  }

  Future<void> _scheduleFullAlarm(
      Schedule schedule, DateTime scheduledTime) async {
    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      schedule.id.hashCode,
      _fullAlarmCallback,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      rescheduleOnReboot: true,
      params: {
        'scheduleId': schedule.id,
        'title': schedule.title,
        'description': schedule.description,
      },
    );
  }

  Future<void> _scheduleNotification(
      Schedule schedule, DateTime scheduledTime) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'schedule_channel',
        'Jadwal Kegiatan',
        channelDescription: 'Notifikasi untuk jadwal kegiatan',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: schedule.color != null
            ? Color(schedule.color!)
            : null,
      ),
    );

    await _notifications.zonedSchedule(
      schedule.id.hashCode,
      schedule.title,
      schedule.description ?? 'Waktunya kegiatan!',
      tz.TZDateTime.from(scheduledTime.toUtc(), tz.UTC),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelAlarm(String scheduleId) async {
    await AndroidAlarmManager.cancel(scheduleId.hashCode);
    await _notifications.cancel(scheduleId.hashCode);
  }

  Future<void> rescheduleAllAlarms(List<Schedule> schedules) async {
    for (final schedule in schedules) {
      if (schedule.isActive) {
        await scheduleAlarm(schedule);
      }
    }
  }

  /// Check if required permissions are granted for this schedule
  Future<bool> _checkRequiredPermissions(Schedule schedule) async {
    if (Platform.isAndroid) {
      final hasNotificationPermission =
          await _permissionService.isNotificationPermissionGranted();
      if (!hasNotificationPermission) return false;

      if (schedule.notificationType == NotificationType.fullAlarm) {
        final hasExactAlarm = await _permissionService.canScheduleExactAlarms();
        if (!hasExactAlarm) return false;
      }
    }
    return true;
  }

  /// Check if the user needs to grant permissions for alarm functionality
  Future<bool> checkUserNeedsPermissions() async {
    if (!Platform.isAndroid) return false;

    final hasNotification =
        await _permissionService.isNotificationPermissionGranted();
    final hasExactAlarm = await _permissionService.canScheduleExactAlarms();

    return !hasNotification || !hasExactAlarm;
  }

  static void _fullAlarmCallback(int id, Map<String, dynamic> params) {
    // This runs in a separate isolate.
    // Trigger foreground service for full alarm.
  }
}