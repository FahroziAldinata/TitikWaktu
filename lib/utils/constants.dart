class AppConstants {
  AppConstants._();
  
  static const String appName = 'Titik Waktu';
  static const String appVersion = '1.0.0';
  
  static const int minSdkVersion = 26;
  static const int targetSdkVersion = 34;
  
  static const Duration alarmSnoozeDuration = Duration(minutes: 5);
  static const Duration notificationTimeout = Duration(seconds: 10);
  
  static const int maxSnoozeCount = 3;
  static const int maxAlarmDurationMinutes = 30;
  
  static const List<String> defaultAlarmSounds = [
    'assets/sounds/default_alarm.mp3',
    'assets/sounds/gentle_chime.mp3',
    'assets/sounds/urgent_alarm.mp3',
  ];
  
  static const List<String> defaultNotificationSounds = [
    'assets/sounds/default_notification.mp3',
    'assets/sounds/soft_notification.mp3',
  ];
  
  static const Map<String, String> dayNames = {
    'mon': 'Senin',
    'tue': 'Selasa',
    'wed': 'Rabu',
    'thu': 'Kamis',
    'fri': 'Jumat',
    'sat': 'Sabtu',
    'sun': 'Minggu',
  };
  
  static const Map<int, String> monthNames = {
    1: 'Januari',
    2: 'Februari',
    3: 'Maret',
    4: 'April',
    5: 'Mei',
    6: 'Juni',
    7: 'Juli',
    8: 'Agustus',
    9: 'September',
    10: 'Oktober',
    11: 'November',
    12: 'Desember',
  };
}
