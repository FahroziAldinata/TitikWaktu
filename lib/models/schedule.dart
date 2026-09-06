import 'package:drift/drift.dart';

@DataClassName('Schedule')
class Schedules extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get time => dateTime()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  IntColumn get notificationType => intEnum<NotificationType>()();
  TextColumn get soundPath => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get recurrenceType => intEnum<RecurrenceType>()();
  TextColumn get recurrenceRule => text().nullable()();
  IntColumn get interval => integer().withDefault(const Constant(1))();
  TextColumn get daysOfWeek => text().nullable()();
  IntColumn get dayOfMonth => integer().nullable()();
  TextColumn get monthPattern => text().nullable()();
  IntColumn get endCount => integer().nullable()();
  TextColumn get exceptionDates => text().nullable()();
  TextColumn get rescheduledDates => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

enum NotificationType {
  fullAlarm,
  notification,
}

enum RecurrenceType {
  once,
  daily,
  weekly,
  monthly,
  customInterval,
}
