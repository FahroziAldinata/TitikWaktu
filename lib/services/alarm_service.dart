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
  }

  Future<dynamic> _handleNativeMethodCall(MethodCall call) async {
    if (call.method == 'rescheduleAllAlarms') {
      if (_onRescheduleRequested != null) {
        final schedules = await _onRescheduleRequested!();
        await rescheduleAllAlarms(schedules);
      }
      return true;
    }
    return null;
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
        'scheduleId': schedule.id,
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