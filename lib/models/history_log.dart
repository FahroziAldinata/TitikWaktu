import 'package:drift/drift.dart';

class HistoryLogs extends Table {
  TextColumn get id => text()();
  TextColumn get scheduleId => text()();
  DateTimeColumn get scheduledTime => dateTime()();
  DateTimeColumn get triggeredAt => dateTime().nullable()();
  IntColumn get status => intEnum<AlarmStatus>()();
  IntColumn get snoozeCount => integer().withDefault(const Constant(0))();
  IntColumn get dismissType => intEnum<DismissType>()();
  TextColumn get notes => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

enum AlarmStatus {
  scheduled,
  triggered,
  dismissed,
  snoozed,
  missed,
  rescheduled,
}

enum DismissType {
  none,
  swiped,
  button,
  autoDismissed,
}
