import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    await _createNotificationChannels();
  }
  
  Future<void> _createNotificationChannels() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          'schedule_channel',
          'Jadwal Kegiatan',
          description: 'Notifikasi untuk jadwal kegiatan',
          importance: Importance.high,
          enableVibration: true,
        ),
      );
      
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          'alarm_channel',
          'Alarm Kegiatan',
          description: 'Channel untuk alarm kegiatan penuh',
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
        ),
      );
    }
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // Navigate to schedule detail
  }
  
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'schedule_channel',
        'Jadwal Kegiatan',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    
    await _notifications.show(id, title, body, details, payload: payload);
  }
}
