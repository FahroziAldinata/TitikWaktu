import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/services/permission_service.dart';
import 'package:timezone/timezone.dart' as tz;

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  static const MethodChannel _nativeAlarmChannel =
      MethodChannel('com.titikwaktu.alarm/native_alarm');

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final PermissionService _permissionService = PermissionService();
  Future<List<Schedule>> Function()? _onRescheduleRequested;

  /// Register callback to load schedules on reboot/reschedule request
  void setRescheduleProvider(Future<List<Schedule>> Function() provider) {
    _onRescheduleRequested = provider;
  }

  Future<void> initialize() async {
    final initializationSettings = const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _nativeAlarmChannel.setMethodCallHandler(_handleNativeMethodCall);

    // Automatically reschedule all active alarms from DB on startup/boot
    try {
      final db = AppDatabase();
      final schedules = await db.schedulesDao.getAllSchedules();
      await rescheduleAllAlarms(schedules);
    } catch (e) {
      debugPrint('Auto-reschedule on init error: $e');
    }
  }

  Future<dynamic> _handleNativeMethodCall(MethodCall call) async {
    if (call.method == 'rescheduleAllAlarms') {
      try {
        List<Schedule> schedules;
        if (_onRescheduleRequested != null) {
          schedules = await _onRescheduleRequested!();
        } else {
          final db = AppDatabase();
          schedules = await db.schedulesDao.getAllSchedules();
        }
        await rescheduleAllAlarms(schedules);
        return true;
      } catch (e) {
        debugPrint('Error handling rescheduleAllAlarms: $e');
        return false;
      }
    }
    return null;
  }

  Future<bool> scheduleAlarm(Schedule schedule) async {
    if (!schedule.isActive) return false;

    final hasPermissions = await _checkRequiredPermissions(schedule);
    if (!hasPermissions) return false;

    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      schedule.startDate?.year ?? now.year,
      schedule.startDate?.month ?? now.month,
      schedule.startDate?.day ?? now.day,
      schedule.time.hour,
      schedule.time.minute,
    );

    if (scheduledTime.isBefore(now)) {
      final todayTime = DateTime(
        now.year,
        now.month,
        now.day,
        schedule.time.hour,
        schedule.time.minute,
      );
      if (todayTime.isAfter(now)) {
        scheduledTime = todayTime;
      } else {
        scheduledTime = todayTime.add(const Duration(days: 1));
      }
    }

    final isFullAlarm = schedule.notificationType == NotificationType.fullAlarm.value;

    if (isFullAlarm) {
      // Use native AlarmManager with looping ForegroundService and WakeLock
      return await _scheduleNativeAlarm(schedule, scheduledTime);
    } else {
      // Use standard local notification
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

      return true;
    }
  }

  Future<bool> _scheduleNativeAlarm(
      Schedule schedule, DateTime scheduledTime) async {
    try {
      await _nativeAlarmChannel.invokeMethod('scheduleAlarm', {
        'scheduleId': schedule.id.toString(),
        'triggerTimeMillis': scheduledTime.millisecondsSinceEpoch,
        'title': schedule.title,
        'description': schedule.description ?? 'Waktunya kegiatan!',
      });
      return true;
    } on PlatformException catch (e) {
      debugPrint('Failed to schedule native alarm: ${e.message}');
      return false;
    }
  }

  Future<void> cancelAlarm(String scheduleId) async {
    await _notifications.cancel(scheduleId.hashCode);
    try {
      await _nativeAlarmChannel.invokeMethod('cancelAlarm', {
        'scheduleId': scheduleId,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to cancel native alarm: ${e.message}');
    }
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

      // Check for exact alarm permission if needed
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

  void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.id}');
  }
}