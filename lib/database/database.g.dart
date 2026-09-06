// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, Schedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
      'time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notificationTypeMeta =
      const VerificationMeta('notificationType');
  @override
  late final GeneratedColumn<int> notificationType = GeneratedColumn<int>(
      'notification_type', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _soundPathMeta =
      const VerificationMeta('soundPath');
  @override
  late final GeneratedColumn<String> soundPath = GeneratedColumn<String>(
      'sound_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0xFFFFFFFF));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _recurrenceTypeMeta =
      const VerificationMeta('recurrenceType');
  @override
  late final GeneratedColumn<int> recurrenceType = GeneratedColumn<int>(
      'recurrence_type', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _recurrenceRuleMeta =
      const VerificationMeta('recurrenceRule');
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
      'recurrence_rule', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _intervalMeta =
      const VerificationMeta('interval');
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
      'interval', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _daysOfWeekMeta =
      const VerificationMeta('daysOfWeek');
  @override
  late final GeneratedColumn<int> daysOfWeek = GeneratedColumn<int>(
      'days_of_week', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dayOfMonthMeta =
      const VerificationMeta('dayOfMonth');
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
      'day_of_month', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _monthPatternMeta =
      const VerificationMeta('monthPattern');
  @override
  late final GeneratedColumn<int> monthPattern = GeneratedColumn<int>(
      'month_pattern', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _endCountMeta =
      const VerificationMeta('endCount');
  @override
  late final GeneratedColumn<int> endCount = GeneratedColumn<int>(
      'end_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _exceptionDatesMeta =
      const VerificationMeta('exceptionDates');
  @override
  late final GeneratedColumn<String> exceptionDates = GeneratedColumn<String>(
      'exception_dates', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rescheduledDatesMeta =
      const VerificationMeta('rescheduledDates');
  @override
  late final GeneratedColumn<String> rescheduledDates = GeneratedColumn<String>(
      'rescheduled_dates', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        time,
        startDate,
        endDate,
        notificationType,
        soundPath,
        color,
        isActive,
        recurrenceType,
        recurrenceRule,
        interval,
        daysOfWeek,
        dayOfMonth,
        monthPattern,
        endCount,
        exceptionDates,
        rescheduledDates,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(Insertable<Schedule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('notification_type')) {
      context.handle(
          _notificationTypeMeta,
          notificationType.isAcceptableOrUnknown(
              data['notification_type']!, _notificationTypeMeta));
    }
    if (data.containsKey('sound_path')) {
      context.handle(_soundPathMeta,
          soundPath.isAcceptableOrUnknown(data['sound_path']!, _soundPathMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('recurrence_type')) {
      context.handle(
          _recurrenceTypeMeta,
          recurrenceType.isAcceptableOrUnknown(
              data['recurrence_type']!, _recurrenceTypeMeta));
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
          _recurrenceRuleMeta,
          recurrenceRule.isAcceptableOrUnknown(
              data['recurrence_rule']!, _recurrenceRuleMeta));
    }
    if (data.containsKey('interval')) {
      context.handle(_intervalMeta,
          interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta));
    }
    if (data.containsKey('days_of_week')) {
      context.handle(
          _daysOfWeekMeta,
          daysOfWeek.isAcceptableOrUnknown(
              data['days_of_week']!, _daysOfWeekMeta));
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
          _dayOfMonthMeta,
          dayOfMonth.isAcceptableOrUnknown(
              data['day_of_month']!, _dayOfMonthMeta));
    }
    if (data.containsKey('month_pattern')) {
      context.handle(
          _monthPatternMeta,
          monthPattern.isAcceptableOrUnknown(
              data['month_pattern']!, _monthPatternMeta));
    }
    if (data.containsKey('end_count')) {
      context.handle(_endCountMeta,
          endCount.isAcceptableOrUnknown(data['end_count']!, _endCountMeta));
    }
    if (data.containsKey('exception_dates')) {
      context.handle(
          _exceptionDatesMeta,
          exceptionDates.isAcceptableOrUnknown(
              data['exception_dates']!, _exceptionDatesMeta));
    }
    if (data.containsKey('rescheduled_dates')) {
      context.handle(
          _rescheduledDatesMeta,
          rescheduledDates.isAcceptableOrUnknown(
              data['rescheduled_dates']!, _rescheduledDatesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Schedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Schedule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      notificationType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}notification_type']),
      soundPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sound_path']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      recurrenceType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recurrence_type']),
      recurrenceRule: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurrence_rule']),
      interval: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval']),
      daysOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}days_of_week']),
      dayOfMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_month']),
      monthPattern: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}month_pattern']),
      endCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_count']),
      exceptionDates: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exception_dates']),
      rescheduledDates: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}rescheduled_dates']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }
}

class Schedule extends DataClass implements Insertable<Schedule> {
  final int id;
  final String title;
  final String? description;
  final DateTime time;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? notificationType;
  final String? soundPath;
  final int? color;
  final bool isActive;
  final int? recurrenceType;
  final String? recurrenceRule;
  final int? interval;
  final int? daysOfWeek;
  final int? dayOfMonth;
  final int? monthPattern;
  final int? endCount;
  final String? exceptionDates;
  final String? rescheduledDates;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Schedule(
      {required this.id,
      required this.title,
      this.description,
      required this.time,
      this.startDate,
      this.endDate,
      this.notificationType,
      this.soundPath,
      this.color,
      required this.isActive,
      this.recurrenceType,
      this.recurrenceRule,
      this.interval,
      this.daysOfWeek,
      this.dayOfMonth,
      this.monthPattern,
      this.endCount,
      this.exceptionDates,
      this.rescheduledDates,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['time'] = Variable<DateTime>(time);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || notificationType != null) {
      map['notification_type'] = Variable<int>(notificationType);
    }
    if (!nullToAbsent || soundPath != null) {
      map['sound_path'] = Variable<String>(soundPath);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || recurrenceType != null) {
      map['recurrence_type'] = Variable<int>(recurrenceType);
    }
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    if (!nullToAbsent || interval != null) {
      map['interval'] = Variable<int>(interval);
    }
    if (!nullToAbsent || daysOfWeek != null) {
      map['days_of_week'] = Variable<int>(daysOfWeek);
    }
    if (!nullToAbsent || dayOfMonth != null) {
      map['day_of_month'] = Variable<int>(dayOfMonth);
    }
    if (!nullToAbsent || monthPattern != null) {
      map['month_pattern'] = Variable<int>(monthPattern);
    }
    if (!nullToAbsent || endCount != null) {
      map['end_count'] = Variable<int>(endCount);
    }
    if (!nullToAbsent || exceptionDates != null) {
      map['exception_dates'] = Variable<String>(exceptionDates);
    }
    if (!nullToAbsent || rescheduledDates != null) {
      map['rescheduled_dates'] = Variable<String>(rescheduledDates);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SchedulesCompanion toCompanion(bool nullToAbsent) {
    return SchedulesCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      time: Value(time),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      notificationType: notificationType == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationType),
      soundPath: soundPath == null && nullToAbsent
          ? const Value.absent()
          : Value(soundPath),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      isActive: Value(isActive),
      recurrenceType: recurrenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceType),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      interval: interval == null && nullToAbsent
          ? const Value.absent()
          : Value(interval),
      daysOfWeek: daysOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(daysOfWeek),
      dayOfMonth: dayOfMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfMonth),
      monthPattern: monthPattern == null && nullToAbsent
          ? const Value.absent()
          : Value(monthPattern),
      endCount: endCount == null && nullToAbsent
          ? const Value.absent()
          : Value(endCount),
      exceptionDates: exceptionDates == null && nullToAbsent
          ? const Value.absent()
          : Value(exceptionDates),
      rescheduledDates: rescheduledDates == null && nullToAbsent
          ? const Value.absent()
          : Value(rescheduledDates),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Schedule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Schedule(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      time: serializer.fromJson<DateTime>(json['time']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      notificationType: serializer.fromJson<int?>(json['notificationType']),
      soundPath: serializer.fromJson<String?>(json['soundPath']),
      color: serializer.fromJson<int?>(json['color']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      recurrenceType: serializer.fromJson<int?>(json['recurrenceType']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      interval: serializer.fromJson<int?>(json['interval']),
      daysOfWeek: serializer.fromJson<int?>(json['daysOfWeek']),
      dayOfMonth: serializer.fromJson<int?>(json['dayOfMonth']),
      monthPattern: serializer.fromJson<int?>(json['monthPattern']),
      endCount: serializer.fromJson<int?>(json['endCount']),
      exceptionDates: serializer.fromJson<String?>(json['exceptionDates']),
      rescheduledDates: serializer.fromJson<String?>(json['rescheduledDates']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'time': serializer.toJson<DateTime>(time),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'notificationType': serializer.toJson<int?>(notificationType),
      'soundPath': serializer.toJson<String?>(soundPath),
      'color': serializer.toJson<int?>(color),
      'isActive': serializer.toJson<bool>(isActive),
      'recurrenceType': serializer.toJson<int?>(recurrenceType),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'interval': serializer.toJson<int?>(interval),
      'daysOfWeek': serializer.toJson<int?>(daysOfWeek),
      'dayOfMonth': serializer.toJson<int?>(dayOfMonth),
      'monthPattern': serializer.toJson<int?>(monthPattern),
      'endCount': serializer.toJson<int?>(endCount),
      'exceptionDates': serializer.toJson<String?>(exceptionDates),
      'rescheduledDates': serializer.toJson<String?>(rescheduledDates),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Schedule copyWith(
          {int? id,
          String? title,
          Value<String?> description = const Value.absent(),
          DateTime? time,
          Value<DateTime?> startDate = const Value.absent(),
          Value<DateTime?> endDate = const Value.absent(),
          Value<int?> notificationType = const Value.absent(),
          Value<String?> soundPath = const Value.absent(),
          Value<int?> color = const Value.absent(),
          bool? isActive,
          Value<int?> recurrenceType = const Value.absent(),
          Value<String?> recurrenceRule = const Value.absent(),
          Value<int?> interval = const Value.absent(),
          Value<int?> daysOfWeek = const Value.absent(),
          Value<int?> dayOfMonth = const Value.absent(),
          Value<int?> monthPattern = const Value.absent(),
          Value<int?> endCount = const Value.absent(),
          Value<String?> exceptionDates = const Value.absent(),
          Value<String?> rescheduledDates = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Schedule(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        time: time ?? this.time,
        startDate: startDate.present ? startDate.value : this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        notificationType: notificationType.present
            ? notificationType.value
            : this.notificationType,
        soundPath: soundPath.present ? soundPath.value : this.soundPath,
        color: color.present ? color.value : this.color,
        isActive: isActive ?? this.isActive,
        recurrenceType:
            recurrenceType.present ? recurrenceType.value : this.recurrenceType,
        recurrenceRule:
            recurrenceRule.present ? recurrenceRule.value : this.recurrenceRule,
        interval: interval.present ? interval.value : this.interval,
        daysOfWeek: daysOfWeek.present ? daysOfWeek.value : this.daysOfWeek,
        dayOfMonth: dayOfMonth.present ? dayOfMonth.value : this.dayOfMonth,
        monthPattern:
            monthPattern.present ? monthPattern.value : this.monthPattern,
        endCount: endCount.present ? endCount.value : this.endCount,
        exceptionDates:
            exceptionDates.present ? exceptionDates.value : this.exceptionDates,
        rescheduledDates: rescheduledDates.present
            ? rescheduledDates.value
            : this.rescheduledDates,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Schedule copyWithCompanion(SchedulesCompanion data) {
    return Schedule(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      time: data.time.present ? data.time.value : this.time,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      notificationType: data.notificationType.present
          ? data.notificationType.value
          : this.notificationType,
      soundPath: data.soundPath.present ? data.soundPath.value : this.soundPath,
      color: data.color.present ? data.color.value : this.color,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      recurrenceType: data.recurrenceType.present
          ? data.recurrenceType.value
          : this.recurrenceType,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      interval: data.interval.present ? data.interval.value : this.interval,
      daysOfWeek:
          data.daysOfWeek.present ? data.daysOfWeek.value : this.daysOfWeek,
      dayOfMonth:
          data.dayOfMonth.present ? data.dayOfMonth.value : this.dayOfMonth,
      monthPattern: data.monthPattern.present
          ? data.monthPattern.value
          : this.monthPattern,
      endCount: data.endCount.present ? data.endCount.value : this.endCount,
      exceptionDates: data.exceptionDates.present
          ? data.exceptionDates.value
          : this.exceptionDates,
      rescheduledDates: data.rescheduledDates.present
          ? data.rescheduledDates.value
          : this.rescheduledDates,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Schedule(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('time: $time, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notificationType: $notificationType, ')
          ..write('soundPath: $soundPath, ')
          ..write('color: $color, ')
          ..write('isActive: $isActive, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('interval: $interval, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('monthPattern: $monthPattern, ')
          ..write('endCount: $endCount, ')
          ..write('exceptionDates: $exceptionDates, ')
          ..write('rescheduledDates: $rescheduledDates, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        title,
        description,
        time,
        startDate,
        endDate,
        notificationType,
        soundPath,
        color,
        isActive,
        recurrenceType,
        recurrenceRule,
        interval,
        daysOfWeek,
        dayOfMonth,
        monthPattern,
        endCount,
        exceptionDates,
        rescheduledDates,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Schedule &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.time == this.time &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.notificationType == this.notificationType &&
          other.soundPath == this.soundPath &&
          other.color == this.color &&
          other.isActive == this.isActive &&
          other.recurrenceType == this.recurrenceType &&
          other.recurrenceRule == this.recurrenceRule &&
          other.interval == this.interval &&
          other.daysOfWeek == this.daysOfWeek &&
          other.dayOfMonth == this.dayOfMonth &&
          other.monthPattern == this.monthPattern &&
          other.endCount == this.endCount &&
          other.exceptionDates == this.exceptionDates &&
          other.rescheduledDates == this.rescheduledDates &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SchedulesCompanion extends UpdateCompanion<Schedule> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> time;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<int?> notificationType;
  final Value<String?> soundPath;
  final Value<int?> color;
  final Value<bool> isActive;
  final Value<int?> recurrenceType;
  final Value<String?> recurrenceRule;
  final Value<int?> interval;
  final Value<int?> daysOfWeek;
  final Value<int?> dayOfMonth;
  final Value<int?> monthPattern;
  final Value<int?> endCount;
  final Value<String?> exceptionDates;
  final Value<String?> rescheduledDates;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.time = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.notificationType = const Value.absent(),
    this.soundPath = const Value.absent(),
    this.color = const Value.absent(),
    this.isActive = const Value.absent(),
    this.recurrenceType = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.interval = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.monthPattern = const Value.absent(),
    this.endCount = const Value.absent(),
    this.exceptionDates = const Value.absent(),
    this.rescheduledDates = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SchedulesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required DateTime time,
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.notificationType = const Value.absent(),
    this.soundPath = const Value.absent(),
    this.color = const Value.absent(),
    this.isActive = const Value.absent(),
    this.recurrenceType = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.interval = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.monthPattern = const Value.absent(),
    this.endCount = const Value.absent(),
    this.exceptionDates = const Value.absent(),
    this.rescheduledDates = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : title = Value(title),
        time = Value(time);
  static Insertable<Schedule> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? time,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? notificationType,
    Expression<String>? soundPath,
    Expression<int>? color,
    Expression<bool>? isActive,
    Expression<int>? recurrenceType,
    Expression<String>? recurrenceRule,
    Expression<int>? interval,
    Expression<int>? daysOfWeek,
    Expression<int>? dayOfMonth,
    Expression<int>? monthPattern,
    Expression<int>? endCount,
    Expression<String>? exceptionDates,
    Expression<String>? rescheduledDates,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (time != null) 'time': time,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (notificationType != null) 'notification_type': notificationType,
      if (soundPath != null) 'sound_path': soundPath,
      if (color != null) 'color': color,
      if (isActive != null) 'is_active': isActive,
      if (recurrenceType != null) 'recurrence_type': recurrenceType,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (interval != null) 'interval': interval,
      if (daysOfWeek != null) 'days_of_week': daysOfWeek,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (monthPattern != null) 'month_pattern': monthPattern,
      if (endCount != null) 'end_count': endCount,
      if (exceptionDates != null) 'exception_dates': exceptionDates,
      if (rescheduledDates != null) 'rescheduled_dates': rescheduledDates,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SchedulesCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<DateTime>? time,
      Value<DateTime?>? startDate,
      Value<DateTime?>? endDate,
      Value<int?>? notificationType,
      Value<String?>? soundPath,
      Value<int?>? color,
      Value<bool>? isActive,
      Value<int?>? recurrenceType,
      Value<String?>? recurrenceRule,
      Value<int?>? interval,
      Value<int?>? daysOfWeek,
      Value<int?>? dayOfMonth,
      Value<int?>? monthPattern,
      Value<int?>? endCount,
      Value<String?>? exceptionDates,
      Value<String?>? rescheduledDates,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return SchedulesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notificationType: notificationType ?? this.notificationType,
      soundPath: soundPath ?? this.soundPath,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      monthPattern: monthPattern ?? this.monthPattern,
      endCount: endCount ?? this.endCount,
      exceptionDates: exceptionDates ?? this.exceptionDates,
      rescheduledDates: rescheduledDates ?? this.rescheduledDates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (notificationType.present) {
      map['notification_type'] = Variable<int>(notificationType.value);
    }
    if (soundPath.present) {
      map['sound_path'] = Variable<String>(soundPath.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (recurrenceType.present) {
      map['recurrence_type'] = Variable<int>(recurrenceType.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (daysOfWeek.present) {
      map['days_of_week'] = Variable<int>(daysOfWeek.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (monthPattern.present) {
      map['month_pattern'] = Variable<int>(monthPattern.value);
    }
    if (endCount.present) {
      map['end_count'] = Variable<int>(endCount.value);
    }
    if (exceptionDates.present) {
      map['exception_dates'] = Variable<String>(exceptionDates.value);
    }
    if (rescheduledDates.present) {
      map['rescheduled_dates'] = Variable<String>(rescheduledDates.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('time: $time, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notificationType: $notificationType, ')
          ..write('soundPath: $soundPath, ')
          ..write('color: $color, ')
          ..write('isActive: $isActive, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('interval: $interval, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('monthPattern: $monthPattern, ')
          ..write('endCount: $endCount, ')
          ..write('exceptionDates: $exceptionDates, ')
          ..write('rescheduledDates: $rescheduledDates, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $HistoryLogsTable extends HistoryLogs
    with TableInfo<$HistoryLogsTable, HistoryLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, action, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_logs';
  @override
  VerificationContext validateIntegrity(Insertable<HistoryLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $HistoryLogsTable createAlias(String alias) {
    return $HistoryLogsTable(attachedDatabase, alias);
  }
}

class HistoryLog extends DataClass implements Insertable<HistoryLog> {
  final int id;
  final String action;
  final DateTime timestamp;
  const HistoryLog(
      {required this.id, required this.action, required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action'] = Variable<String>(action);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  HistoryLogsCompanion toCompanion(bool nullToAbsent) {
    return HistoryLogsCompanion(
      id: Value(id),
      action: Value(action),
      timestamp: Value(timestamp),
    );
  }

  factory HistoryLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryLog(
      id: serializer.fromJson<int>(json['id']),
      action: serializer.fromJson<String>(json['action']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'action': serializer.toJson<String>(action),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  HistoryLog copyWith({int? id, String? action, DateTime? timestamp}) =>
      HistoryLog(
        id: id ?? this.id,
        action: action ?? this.action,
        timestamp: timestamp ?? this.timestamp,
      );
  HistoryLog copyWithCompanion(HistoryLogsCompanion data) {
    return HistoryLog(
      id: data.id.present ? data.id.value : this.id,
      action: data.action.present ? data.action.value : this.action,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryLog(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, action, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryLog &&
          other.id == this.id &&
          other.action == this.action &&
          other.timestamp == this.timestamp);
}

class HistoryLogsCompanion extends UpdateCompanion<HistoryLog> {
  final Value<int> id;
  final Value<String> action;
  final Value<DateTime> timestamp;
  const HistoryLogsCompanion({
    this.id = const Value.absent(),
    this.action = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  HistoryLogsCompanion.insert({
    this.id = const Value.absent(),
    required String action,
    this.timestamp = const Value.absent(),
  }) : action = Value(action);
  static Insertable<HistoryLog> custom({
    Expression<int>? id,
    Expression<String>? action,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (action != null) 'action': action,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  HistoryLogsCompanion copyWith(
      {Value<int>? id, Value<String>? action, Value<DateTime>? timestamp}) {
    return HistoryLogsCompanion(
      id: id ?? this.id,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryLogsCompanion(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  late final $HistoryLogsTable historyLogs = $HistoryLogsTable(this);
  late final SchedulesDao schedulesDao = SchedulesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [schedules, historyLogs];
}

typedef $$SchedulesTableCreateCompanionBuilder = SchedulesCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> description,
  required DateTime time,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<int?> notificationType,
  Value<String?> soundPath,
  Value<int?> color,
  Value<bool> isActive,
  Value<int?> recurrenceType,
  Value<String?> recurrenceRule,
  Value<int?> interval,
  Value<int?> daysOfWeek,
  Value<int?> dayOfMonth,
  Value<int?> monthPattern,
  Value<int?> endCount,
  Value<String?> exceptionDates,
  Value<String?> rescheduledDates,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$SchedulesTableUpdateCompanionBuilder = SchedulesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> description,
  Value<DateTime> time,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<int?> notificationType,
  Value<String?> soundPath,
  Value<int?> color,
  Value<bool> isActive,
  Value<int?> recurrenceType,
  Value<String?> recurrenceRule,
  Value<int?> interval,
  Value<int?> daysOfWeek,
  Value<int?> dayOfMonth,
  Value<int?> monthPattern,
  Value<int?> endCount,
  Value<String?> exceptionDates,
  Value<String?> rescheduledDates,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$SchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get notificationType => $composableBuilder(
      column: $table.notificationType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get soundPath => $composableBuilder(
      column: $table.soundPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recurrenceType => $composableBuilder(
      column: $table.recurrenceType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceRule => $composableBuilder(
      column: $table.recurrenceRule,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get daysOfWeek => $composableBuilder(
      column: $table.daysOfWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
      column: $table.dayOfMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get monthPattern => $composableBuilder(
      column: $table.monthPattern, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endCount => $composableBuilder(
      column: $table.endCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exceptionDates => $composableBuilder(
      column: $table.exceptionDates,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rescheduledDates => $composableBuilder(
      column: $table.rescheduledDates,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get notificationType => $composableBuilder(
      column: $table.notificationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get soundPath => $composableBuilder(
      column: $table.soundPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recurrenceType => $composableBuilder(
      column: $table.recurrenceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceRule => $composableBuilder(
      column: $table.recurrenceRule,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get daysOfWeek => $composableBuilder(
      column: $table.daysOfWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
      column: $table.dayOfMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monthPattern => $composableBuilder(
      column: $table.monthPattern,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endCount => $composableBuilder(
      column: $table.endCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exceptionDates => $composableBuilder(
      column: $table.exceptionDates,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rescheduledDates => $composableBuilder(
      column: $table.rescheduledDates,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get notificationType => $composableBuilder(
      column: $table.notificationType, builder: (column) => column);

  GeneratedColumn<String> get soundPath =>
      $composableBuilder(column: $table.soundPath, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get recurrenceType => $composableBuilder(
      column: $table.recurrenceType, builder: (column) => column);

  GeneratedColumn<String> get recurrenceRule => $composableBuilder(
      column: $table.recurrenceRule, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<int> get daysOfWeek => $composableBuilder(
      column: $table.daysOfWeek, builder: (column) => column);

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
      column: $table.dayOfMonth, builder: (column) => column);

  GeneratedColumn<int> get monthPattern => $composableBuilder(
      column: $table.monthPattern, builder: (column) => column);

  GeneratedColumn<int> get endCount =>
      $composableBuilder(column: $table.endCount, builder: (column) => column);

  GeneratedColumn<String> get exceptionDates => $composableBuilder(
      column: $table.exceptionDates, builder: (column) => column);

  GeneratedColumn<String> get rescheduledDates => $composableBuilder(
      column: $table.rescheduledDates, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SchedulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SchedulesTable,
    Schedule,
    $$SchedulesTableFilterComposer,
    $$SchedulesTableOrderingComposer,
    $$SchedulesTableAnnotationComposer,
    $$SchedulesTableCreateCompanionBuilder,
    $$SchedulesTableUpdateCompanionBuilder,
    (Schedule, BaseReferences<_$AppDatabase, $SchedulesTable, Schedule>),
    Schedule,
    PrefetchHooks Function()> {
  $$SchedulesTableTableManager(_$AppDatabase db, $SchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> time = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<int?> notificationType = const Value.absent(),
            Value<String?> soundPath = const Value.absent(),
            Value<int?> color = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int?> recurrenceType = const Value.absent(),
            Value<String?> recurrenceRule = const Value.absent(),
            Value<int?> interval = const Value.absent(),
            Value<int?> daysOfWeek = const Value.absent(),
            Value<int?> dayOfMonth = const Value.absent(),
            Value<int?> monthPattern = const Value.absent(),
            Value<int?> endCount = const Value.absent(),
            Value<String?> exceptionDates = const Value.absent(),
            Value<String?> rescheduledDates = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SchedulesCompanion(
            id: id,
            title: title,
            description: description,
            time: time,
            startDate: startDate,
            endDate: endDate,
            notificationType: notificationType,
            soundPath: soundPath,
            color: color,
            isActive: isActive,
            recurrenceType: recurrenceType,
            recurrenceRule: recurrenceRule,
            interval: interval,
            daysOfWeek: daysOfWeek,
            dayOfMonth: dayOfMonth,
            monthPattern: monthPattern,
            endCount: endCount,
            exceptionDates: exceptionDates,
            rescheduledDates: rescheduledDates,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            required DateTime time,
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<int?> notificationType = const Value.absent(),
            Value<String?> soundPath = const Value.absent(),
            Value<int?> color = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int?> recurrenceType = const Value.absent(),
            Value<String?> recurrenceRule = const Value.absent(),
            Value<int?> interval = const Value.absent(),
            Value<int?> daysOfWeek = const Value.absent(),
            Value<int?> dayOfMonth = const Value.absent(),
            Value<int?> monthPattern = const Value.absent(),
            Value<int?> endCount = const Value.absent(),
            Value<String?> exceptionDates = const Value.absent(),
            Value<String?> rescheduledDates = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SchedulesCompanion.insert(
            id: id,
            title: title,
            description: description,
            time: time,
            startDate: startDate,
            endDate: endDate,
            notificationType: notificationType,
            soundPath: soundPath,
            color: color,
            isActive: isActive,
            recurrenceType: recurrenceType,
            recurrenceRule: recurrenceRule,
            interval: interval,
            daysOfWeek: daysOfWeek,
            dayOfMonth: dayOfMonth,
            monthPattern: monthPattern,
            endCount: endCount,
            exceptionDates: exceptionDates,
            rescheduledDates: rescheduledDates,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SchedulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SchedulesTable,
    Schedule,
    $$SchedulesTableFilterComposer,
    $$SchedulesTableOrderingComposer,
    $$SchedulesTableAnnotationComposer,
    $$SchedulesTableCreateCompanionBuilder,
    $$SchedulesTableUpdateCompanionBuilder,
    (Schedule, BaseReferences<_$AppDatabase, $SchedulesTable, Schedule>),
    Schedule,
    PrefetchHooks Function()>;
typedef $$HistoryLogsTableCreateCompanionBuilder = HistoryLogsCompanion
    Function({
  Value<int> id,
  required String action,
  Value<DateTime> timestamp,
});
typedef $$HistoryLogsTableUpdateCompanionBuilder = HistoryLogsCompanion
    Function({
  Value<int> id,
  Value<String> action,
  Value<DateTime> timestamp,
});

class $$HistoryLogsTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryLogsTable> {
  $$HistoryLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$HistoryLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryLogsTable> {
  $$HistoryLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$HistoryLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryLogsTable> {
  $$HistoryLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$HistoryLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HistoryLogsTable,
    HistoryLog,
    $$HistoryLogsTableFilterComposer,
    $$HistoryLogsTableOrderingComposer,
    $$HistoryLogsTableAnnotationComposer,
    $$HistoryLogsTableCreateCompanionBuilder,
    $$HistoryLogsTableUpdateCompanionBuilder,
    (HistoryLog, BaseReferences<_$AppDatabase, $HistoryLogsTable, HistoryLog>),
    HistoryLog,
    PrefetchHooks Function()> {
  $$HistoryLogsTableTableManager(_$AppDatabase db, $HistoryLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              HistoryLogsCompanion(
            id: id,
            action: action,
            timestamp: timestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String action,
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              HistoryLogsCompanion.insert(
            id: id,
            action: action,
            timestamp: timestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HistoryLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HistoryLogsTable,
    HistoryLog,
    $$HistoryLogsTableFilterComposer,
    $$HistoryLogsTableOrderingComposer,
    $$HistoryLogsTableAnnotationComposer,
    $$HistoryLogsTableCreateCompanionBuilder,
    $$HistoryLogsTableUpdateCompanionBuilder,
    (HistoryLog, BaseReferences<_$AppDatabase, $HistoryLogsTable, HistoryLog>),
    HistoryLog,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
  $$HistoryLogsTableTableManager get historyLogs =>
      $$HistoryLogsTableTableManager(_db, _db.historyLogs);
}
