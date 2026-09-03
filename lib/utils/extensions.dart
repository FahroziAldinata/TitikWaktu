extension DateTimeExtension on DateTime {
  String get formattedTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
  
  String get formattedDate {
    return '$day/$month/$year';
  }
  
  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }
  
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }
  
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  bool get isPast {
    return isBefore(DateTime.now());
  }
  
  bool get isFuture {
    return isAfter(DateTime.now());
  }
  
  bool get isCurrentHour {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day && hour == now.hour;
  }
}

extension TimeOfDayExtension on TimeOfDay {
  String get formatted {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
  
  bool get isPast {
    final now = TimeOfDay.now();
    return hour < now.hour || (hour == now.hour && minute < now.minute);
  }
  
  bool get isFuture {
    final now = TimeOfDay.now();
    return hour > now.hour || (hour == now.hour && minute > now.minute);
  }
}
