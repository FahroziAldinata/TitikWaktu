import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:titik_waktu/models/schedule.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }
  
  Future<void> scheduleAlarm(Schedule schedule) async {
    if (!schedule.isActive) return;
    
    final scheduledTime = DateTime(
      schedule.startDate.year,
      schedule.startDate.month,
      schedule.startDate.day,
      schedule.time.hour,
      schedule.time.minute,
    );
    
    if (scheduledTime.isBefore(DateTime.now())) return;
    
    if (schedule.notificationType == NotificationType.fullAlarm) {
      await _scheduleFullAlarm(schedule, scheduledTime);
    } else {
      await _scheduleNotification(schedule, scheduledTime);
    }
  }
  
  Future<void> _scheduleFullAlarm(Schedule schedule, DateTime scheduledTime) async {
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
  
  Future<void> _scheduleNotification(Schedule schedule, DateTime scheduledTime) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'schedule_channel',
        'Jadwal Kegiatan',
        channelDescription: 'Notifikasi untuk jadwal kegiatan',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: schedule.color != null 
          ? Color(int.parse(schedule.color!.replaceFirst('#', '0xFF')))
          : null,
      ),
    );
    
    await _notifications.schedule(
      schedule.id.hashCode,
      schedule.title,
      schedule.description ?? 'Waktunya kegiatan!',
      scheduledTime,
      notificationDetails,
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
  
  static void _fullAlarmCallback(int id, Map<String, dynamic> params) {
    // This runs in a separate isolate
    // Trigger foreground service for full alarm
  }
}
