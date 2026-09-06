enum NotificationType {
  none(0),
  push(1),
  email(2),
  sms(3),
  fullAlarm(4),
  notification(5);

  const NotificationType(this.value);
  final int value;

  static NotificationType fromValue(int? value) {
    if (value == null) return none;
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => none,
    );
  }
}

enum RecurrenceType {
  none(0),
  once(1),
  daily(2),
  weekly(3),
  monthly(4),
  yearly(5),
  customInterval(6);

  const RecurrenceType(this.value);
  final int value;

  static RecurrenceType fromValue(int? value) {
    if (value == null) return none;
    return RecurrenceType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => none,
    );
  }
}