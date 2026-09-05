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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
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
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<NotificationType, int>
      notificationType = GeneratedColumn<int>(
              'notification_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<NotificationType>(
              $SchedulesTable.$converternotificationType);
  static const VerificationMeta _soundPathMeta =
      const VerificationMeta('soundPath');
  @override
  late final GeneratedColumn<String> soundPath = GeneratedColumn<String>(
      'sound_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  @override
  late final GeneratedColumnWithTypeConverter<RecurrenceType, int>
      recurrenceType = GeneratedColumn<int>(
              'recurrence_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<RecurrenceType>(
              $SchedulesTable.$converterrecurrenceType);
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
      'interval', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _daysOfWeekMeta =
      const VerificationMeta('daysOfWeek');
  @override
  late final GeneratedColumn<String> daysOfWeek = GeneratedColumn<String>(
      'days_of_week', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dayOfMonthMeta =
      const VerificationMeta('dayOfMonth');
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
      'day_of_month', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _monthPatternMeta =
      const VerificationMeta('monthPattern');
  @override
  late final GeneratedColumn<String> monthPattern = GeneratedColumn<String>(
      'month_pattern', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
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
    } else if (isInserting) {
      context.missing(_idMeta);
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
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
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
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
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
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      notificationType: $SchedulesTable.$converternotificationType.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}notification_type'])!),
      soundPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sound_path']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      recurrenceType: $SchedulesTable.$converterrecurrenceType.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}recurrence_type'])!),
      recurrenceRule: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurrence_rule']),
      interval: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval'])!,
      daysOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}days_of_week']),
      dayOfMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_month']),
      monthPattern: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}month_pattern']),
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

  static JsonTypeConverter2<NotificationType, int, int>
      $converternotificationType =
      const EnumIndexConverter<NotificationType>(NotificationType.values);
  static JsonTypeConverter2<RecurrenceType, int, int> $converterrecurrenceType =
      const EnumIndexConverter<RecurrenceType>(RecurrenceType.values);
}

class Schedule extends DataClass implements Insertable<Schedule> {
  final String id;
  final String title;
  final String? description;
  final DateTime time;
  final DateTime startDate;
  final DateTime? endDate;
  final NotificationType notificationType;
  final String? soundPath;
  final String? color;
  final bool isActive;
  final RecurrenceType recurrenceType;
  final String? recurrenceRule;
  final int interval;
  final String? daysOfWeek;
  final int? dayOfMonth;
  final String? monthPattern;
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
      required this.startDate,
      this.endDate,
      required this.notificationType,
      this.soundPath,
      this.color,
      required this.isActive,
      required this.recurrenceType,
      this.recurrenceRule,
      required this.interval,
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
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['time'] = Variable<DateTime>(time);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    {
      map['notification_type'] = Variable<int>(
          $SchedulesTable.$converternotificationType.toSql(notificationType));
    }
    if (!nullToAbsent || soundPath != null) {
      map['sound_path'] = Variable<String>(soundPath);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['is_active'] = Variable<bool>(isActive);
    {
      map['recurrence_type'] = Variable<int>(
          $SchedulesTable.$converterrecurrenceType.toSql(recurrenceType));
    }
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    map['interval'] = Variable<int>(interval);
    if (!nullToAbsent || daysOfWeek != null) {
      map['days_of_week'] = Variable<String>(daysOfWeek);
    }
    if (!nullToAbsent || dayOfMonth != null) {
      map['day_of_month'] = Variable<int>(dayOfMonth);
    }
    if (!nullToAbsent || monthPattern != null) {
      map['month_pattern'] = Variable<String>(monthPattern);
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
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      notificationType: Value(notificationType),
      soundPath: soundPath == null && nullToAbsent
          ? const Value.absent()
          : Value(soundPath),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      isActive: Value(isActive),
      recurrenceType: Value(recurrenceType),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      interval: Value(interval),
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
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      time: serializer.fromJson<DateTime>(json['time']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      notificationType: $SchedulesTable.$converternotificationType
          .fromJson(serializer.fromJson<int>(json['notificationType'])),
      soundPath: serializer.fromJson<String?>(json['soundPath']),
      color: serializer.fromJson<String?>(json['color']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      recurrenceType: $SchedulesTable.$converterrecurrenceType
          .fromJson(serializer.fromJson<int>(json['recurrenceType'])),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      interval: serializer.fromJson<int>(json['interval']),
      daysOfWeek: serializer.fromJson<String?>(json['daysOfWeek']),
      dayOfMonth: serializer.fromJson<int?>(json['dayOfMonth']),
      monthPattern: serializer.fromJson<String?>(json['monthPattern']),
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
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'time': serializer.toJson<DateTime>(time),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'notificationType': serializer.toJson<int>(
          $SchedulesTable.$converternotificationType.toJson(notificationType)),
      'soundPath': serializer.toJson<String?>(soundPath),
      'color': serializer.toJson<String?>(color),
      'isActive': serializer.toJson<bool>(isActive),
      'recurrenceType': serializer.toJson<int>(
          $SchedulesTable.$converterrecurrenceType.toJson(recurrenceType)),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'interval': serializer.toJson<int>(interval),
      'daysOfWeek': serializer.toJson<String?>(daysOfWeek),
      'dayOfMonth': serializer.toJson<int?>(dayOfMonth),
      'monthPattern': serializer.toJson<String?>(monthPattern),
      'endCount': serializer.toJson<int?>(endCount),
      'exceptionDates': serializer.toJson<String?>(exceptionDates),
      'rescheduledDates': serializer.toJson<String?>(rescheduledDates),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Schedule copyWith(
          {String? id,
          String? title,
          Value<String?> description = const Value.absent(),
          DateTime? time,
          DateTime? startDate,
          Value<DateTime?> endDate = const Value.absent(),
          NotificationType? notificationType,
          Value<String?> soundPath = const Value.absent(),
          Value<String?> color = const Value.absent(),
          bool? isActive,
          RecurrenceType? recurrenceType,
          Value<String?> recurrenceRule = const Value.absent(),
          int? interval,
          Value<String?> daysOfWeek = const Value.absent(),
          Value<int?> dayOfMonth = const Value.absent(),
          Value<String?> monthPattern = const Value.absent(),
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
        startDate: startDate ?? this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        notificationType: notificationType ?? this.notificationType,
        soundPath: soundPath.present ? soundPath.value : this.soundPath,
        color: color.present ? color.value : this.color,
        isActive: isActive ?? this.isActive,
        recurrenceType: recurrenceType ?? this.recurrenceType,
        recurrenceRule:
            recurrenceRule.present ? recurrenceRule.value : this.recurrenceRule,
        interval: interval ?? this.interval,
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
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> time;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<NotificationType> notificationType;
  final Value<String?> soundPath;
  final Value<String?> color;
  final Value<bool> isActive;
  final Value<RecurrenceType> recurrenceType;
  final Value<String?> recurrenceRule;
  final Value<int> interval;
  final Value<String?> daysOfWeek;
  final Value<int?> dayOfMonth;
  final Value<String?> monthPattern;
  final Value<int?> endCount;
  final Value<String?> exceptionDates;
  final Value<String?> rescheduledDates;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
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
    this.rowid = const Value.absent(),
  });
  SchedulesCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required DateTime time,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    required NotificationType notificationType,
    this.soundPath = const Value.absent(),
    this.color = const Value.absent(),
    this.isActive = const Value.absent(),
    required RecurrenceType recurrenceType,
    this.recurrenceRule = const Value.absent(),
    this.interval = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.monthPattern = const Value.absent(),
    this.endCount = const Value.absent(),
    this.exceptionDates = const Value.absent(),
    this.rescheduledDates = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        time = Value(time),
        startDate = Value(startDate),
        notificationType = Value(notificationType),
        recurrenceType = Value(recurrenceType),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Schedule> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? time,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? notificationType,
    Expression<String>? soundPath,
    Expression<String>? color,
    Expression<bool>? isActive,
    Expression<int>? recurrenceType,
    Expression<String>? recurrenceRule,
    Expression<int>? interval,
    Expression<String>? daysOfWeek,
    Expression<int>? dayOfMonth,
    Expression<String>? monthPattern,
    Expression<int>? endCount,
    Expression<String>? exceptionDates,
    Expression<String>? rescheduledDates,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
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
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchedulesCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<DateTime>? time,
      Value<DateTime>? startDate,
      Value<DateTime?>? endDate,
      Value<NotificationType>? notificationType,
      Value<String?>? soundPath,
      Value<String?>? color,
      Value<bool>? isActive,
      Value<RecurrenceType>? recurrenceType,
      Value<String?>? recurrenceRule,
      Value<int>? interval,
      Value<String?>? daysOfWeek,
      Value<int?>? dayOfMonth,
      Value<String?>? monthPattern,
      Value<int?>? endCount,
      Value<String?>? exceptionDates,
      Value<String?>? rescheduledDates,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
      map['notification_type'] = Variable<int>($SchedulesTable
          .$converternotificationType
          .toSql(notificationType.value));
    }
    if (soundPath.present) {
      map['sound_path'] = Variable<String>(soundPath.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (recurrenceType.present) {
      map['recurrence_type'] = Variable<int>(
          $SchedulesTable.$converterrecurrenceType.toSql(recurrenceType.value));
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (daysOfWeek.present) {
      map['days_of_week'] = Variable<String>(daysOfWeek.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (monthPattern.present) {
      map['month_pattern'] = Variable<String>(monthPattern.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
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
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scheduleIdMeta =
      const VerificationMeta('scheduleId');
  @override
  late final GeneratedColumn<String> scheduleId = GeneratedColumn<String>(
      'schedule_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scheduledTimeMeta =
      const VerificationMeta('scheduledTime');
  @override
  late final GeneratedColumn<DateTime> scheduledTime =
      GeneratedColumn<DateTime>('scheduled_time', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _triggeredAtMeta =
      const VerificationMeta('triggeredAt');
  @override
  late final GeneratedColumn<DateTime> triggeredAt = GeneratedColumn<DateTime>(
      'triggered_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<AlarmStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<AlarmStatus>($HistoryLogsTable.$converterstatus);
  static const VerificationMeta _snoozeCountMeta =
      const VerificationMeta('snoozeCount');
  @override
  late final GeneratedColumn<int> snoozeCount = GeneratedColumn<int>(
      'snooze_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  late final GeneratedColumnWithTypeConverter<DismissType, int> dismissType =
      GeneratedColumn<int>('dismiss_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DismissType>($HistoryLogsTable.$converterdismissType);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        scheduleId,
        scheduledTime,
        triggeredAt,
        status,
        snoozeCount,
        dismissType,
        notes
      ];
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
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
          _scheduleIdMeta,
          scheduleId.isAcceptableOrUnknown(
              data['schedule_id']!, _scheduleIdMeta));
    } else if (isInserting) {
      context.missing(_scheduleIdMeta);
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
          _scheduledTimeMeta,
          scheduledTime.isAcceptableOrUnknown(
              data['scheduled_time']!, _scheduledTimeMeta));
    } else if (isInserting) {
      context.missing(_scheduledTimeMeta);
    }
    if (data.containsKey('triggered_at')) {
      context.handle(
          _triggeredAtMeta,
          triggeredAt.isAcceptableOrUnknown(
              data['triggered_at']!, _triggeredAtMeta));
    }
    if (data.containsKey('snooze_count')) {
      context.handle(
          _snoozeCountMeta,
          snoozeCount.isAcceptableOrUnknown(
              data['snooze_count']!, _snoozeCountMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
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
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      scheduleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}schedule_id'])!,
      scheduledTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}scheduled_time'])!,
      triggeredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}triggered_at']),
      status: $HistoryLogsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
      snoozeCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}snooze_count'])!,
      dismissType: $HistoryLogsTable.$converterdismissType.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}dismiss_type'])!),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $HistoryLogsTable createAlias(String alias) {
    return $HistoryLogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AlarmStatus, int, int> $converterstatus =
      const EnumIndexConverter<AlarmStatus>(AlarmStatus.values);
  static JsonTypeConverter2<DismissType, int, int> $converterdismissType =
      const EnumIndexConverter<DismissType>(DismissType.values);
}

class HistoryLog extends DataClass implements Insertable<HistoryLog> {
  final String id;
  final String scheduleId;
  final DateTime scheduledTime;
  final DateTime? triggeredAt;
  final AlarmStatus status;
  final int snoozeCount;
  final DismissType dismissType;
  final String? notes;
  const HistoryLog(
      {required this.id,
      required this.scheduleId,
      required this.scheduledTime,
      this.triggeredAt,
      required this.status,
      required this.snoozeCount,
      required this.dismissType,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['schedule_id'] = Variable<String>(scheduleId);
    map['scheduled_time'] = Variable<DateTime>(scheduledTime);
    if (!nullToAbsent || triggeredAt != null) {
      map['triggered_at'] = Variable<DateTime>(triggeredAt);
    }
    {
      map['status'] =
          Variable<int>($HistoryLogsTable.$converterstatus.toSql(status));
    }
    map['snooze_count'] = Variable<int>(snoozeCount);
    {
      map['dismiss_type'] = Variable<int>(
          $HistoryLogsTable.$converterdismissType.toSql(dismissType));
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  HistoryLogsCompanion toCompanion(bool nullToAbsent) {
    return HistoryLogsCompanion(
      id: Value(id),
      scheduleId: Value(scheduleId),
      scheduledTime: Value(scheduledTime),
      triggeredAt: triggeredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(triggeredAt),
      status: Value(status),
      snoozeCount: Value(snoozeCount),
      dismissType: Value(dismissType),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory HistoryLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryLog(
      id: serializer.fromJson<String>(json['id']),
      scheduleId: serializer.fromJson<String>(json['scheduleId']),
      scheduledTime: serializer.fromJson<DateTime>(json['scheduledTime']),
      triggeredAt: serializer.fromJson<DateTime?>(json['triggeredAt']),
      status: $HistoryLogsTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
      snoozeCount: serializer.fromJson<int>(json['snoozeCount']),
      dismissType: $HistoryLogsTable.$converterdismissType
          .fromJson(serializer.fromJson<int>(json['dismissType'])),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scheduleId': serializer.toJson<String>(scheduleId),
      'scheduledTime': serializer.toJson<DateTime>(scheduledTime),
      'triggeredAt': serializer.toJson<DateTime?>(triggeredAt),
      'status': serializer
          .toJson<int>($HistoryLogsTable.$converterstatus.toJson(status)),
      'snoozeCount': serializer.toJson<int>(snoozeCount),
      'dismissType': serializer.toJson<int>(
          $HistoryLogsTable.$converterdismissType.toJson(dismissType)),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  HistoryLog copyWith(
          {String? id,
          String? scheduleId,
          DateTime? scheduledTime,
          Value<DateTime?> triggeredAt = const Value.absent(),
          AlarmStatus? status,
          int? snoozeCount,
          DismissType? dismissType,
          Value<String?> notes = const Value.absent()}) =>
      HistoryLog(
        id: id ?? this.id,
        scheduleId: scheduleId ?? this.scheduleId,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        triggeredAt: triggeredAt.present ? triggeredAt.value : this.triggeredAt,
        status: status ?? this.status,
        snoozeCount: snoozeCount ?? this.snoozeCount,
        dismissType: dismissType ?? this.dismissType,
        notes: notes.present ? notes.value : this.notes,
      );
  HistoryLog copyWithCompanion(HistoryLogsCompanion data) {
    return HistoryLog(
      id: data.id.present ? data.id.value : this.id,
      scheduleId:
          data.scheduleId.present ? data.scheduleId.value : this.scheduleId,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      triggeredAt:
          data.triggeredAt.present ? data.triggeredAt.value : this.triggeredAt,
      status: data.status.present ? data.status.value : this.status,
      snoozeCount:
          data.snoozeCount.present ? data.snoozeCount.value : this.snoozeCount,
      dismissType:
          data.dismissType.present ? data.dismissType.value : this.dismissType,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryLog(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('triggeredAt: $triggeredAt, ')
          ..write('status: $status, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('dismissType: $dismissType, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, scheduleId, scheduledTime, triggeredAt,
      status, snoozeCount, dismissType, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryLog &&
          other.id == this.id &&
          other.scheduleId == this.scheduleId &&
          other.scheduledTime == this.scheduledTime &&
          other.triggeredAt == this.triggeredAt &&
          other.status == this.status &&
          other.snoozeCount == this.snoozeCount &&
          other.dismissType == this.dismissType &&
          other.notes == this.notes);
}

class HistoryLogsCompanion extends UpdateCompanion<HistoryLog> {
  final Value<String> id;
  final Value<String> scheduleId;
  final Value<DateTime> scheduledTime;
  final Value<DateTime?> triggeredAt;
  final Value<AlarmStatus> status;
  final Value<int> snoozeCount;
  final Value<DismissType> dismissType;
  final Value<String?> notes;
  final Value<int> rowid;
  const HistoryLogsCompanion({
    this.id = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.triggeredAt = const Value.absent(),
    this.status = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.dismissType = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HistoryLogsCompanion.insert({
    required String id,
    required String scheduleId,
    required DateTime scheduledTime,
    this.triggeredAt = const Value.absent(),
    required AlarmStatus status,
    this.snoozeCount = const Value.absent(),
    required DismissType dismissType,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        scheduleId = Value(scheduleId),
        scheduledTime = Value(scheduledTime),
        status = Value(status),
        dismissType = Value(dismissType);
  static Insertable<HistoryLog> custom({
    Expression<String>? id,
    Expression<String>? scheduleId,
    Expression<DateTime>? scheduledTime,
    Expression<DateTime>? triggeredAt,
    Expression<int>? status,
    Expression<int>? snoozeCount,
    Expression<int>? dismissType,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (triggeredAt != null) 'triggered_at': triggeredAt,
      if (status != null) 'status': status,
      if (snoozeCount != null) 'snooze_count': snoozeCount,
      if (dismissType != null) 'dismiss_type': dismissType,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HistoryLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? scheduleId,
      Value<DateTime>? scheduledTime,
      Value<DateTime?>? triggeredAt,
      Value<AlarmStatus>? status,
      Value<int>? snoozeCount,
      Value<DismissType>? dismissType,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return HistoryLogsCompanion(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      status: status ?? this.status,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      dismissType: dismissType ?? this.dismissType,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<String>(scheduleId.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<DateTime>(scheduledTime.value);
    }
    if (triggeredAt.present) {
      map['triggered_at'] = Variable<DateTime>(triggeredAt.value);
    }
    if (status.present) {
      map['status'] =
          Variable<int>($HistoryLogsTable.$converterstatus.toSql(status.value));
    }
    if (snoozeCount.present) {
      map['snooze_count'] = Variable<int>(snoozeCount.value);
    }
    if (dismissType.present) {
      map['dismiss_type'] = Variable<int>(
          $HistoryLogsTable.$converterdismissType.toSql(dismissType.value));
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryLogsCompanion(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('triggeredAt: $triggeredAt, ')
          ..write('status: $status, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('dismissType: $dismissType, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  late final $HistoryLogsTable historyLogs = $HistoryLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [schedules, historyLogs];
}

typedef $$SchedulesTableCreateCompanionBuilder = SchedulesCompanion Function({
  required String id,
  required String title,
  Value<String?> description,
  required DateTime time,
  required DateTime startDate,
  Value<DateTime?> endDate,
  required NotificationType notificationType,
  Value<String?> soundPath,
  Value<String?> color,
  Value<bool> isActive,
  required RecurrenceType recurrenceType,
  Value<String?> recurrenceRule,
  Value<int> interval,
  Value<String?> daysOfWeek,
  Value<int?> dayOfMonth,
  Value<String?> monthPattern,
  Value<int?> endCount,
  Value<String?> exceptionDates,
  Value<String?> rescheduledDates,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SchedulesTableUpdateCompanionBuilder = SchedulesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> description,
  Value<DateTime> time,
  Value<DateTime> startDate,
  Value<DateTime?> endDate,
  Value<NotificationType> notificationType,
  Value<String?> soundPath,
  Value<String?> color,
  Value<bool> isActive,
  Value<RecurrenceType> recurrenceType,
  Value<String?> recurrenceRule,
  Value<int> interval,
  Value<String?> daysOfWeek,
  Value<int?> dayOfMonth,
  Value<String?> monthPattern,
  Value<int?> endCount,
  Value<String?> exceptionDates,
  Value<String?> rescheduledDates,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
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
  ColumnFilters<String> get id => $composableBuilder(
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

  ColumnWithTypeConverterFilters<NotificationType, NotificationType, int>
      get notificationType => $composableBuilder(
          column: $table.notificationType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get soundPath => $composableBuilder(
      column: $table.soundPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<RecurrenceType, RecurrenceType, int>
      get recurrenceType => $composableBuilder(
          column: $table.recurrenceType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get recurrenceRule => $composableBuilder(
      column: $table.recurrenceRule,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get daysOfWeek => $composableBuilder(
      column: $table.daysOfWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
      column: $table.dayOfMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get monthPattern => $composableBuilder(
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
  ColumnOrderings<String> get id => $composableBuilder(
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

  ColumnOrderings<String> get color => $composableBuilder(
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

  ColumnOrderings<String> get daysOfWeek => $composableBuilder(
      column: $table.daysOfWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
      column: $table.dayOfMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get monthPattern => $composableBuilder(
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
  GeneratedColumn<String> get id =>
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

  GeneratedColumnWithTypeConverter<NotificationType, int>
      get notificationType => $composableBuilder(
          column: $table.notificationType, builder: (column) => column);

  GeneratedColumn<String> get soundPath =>
      $composableBuilder(column: $table.soundPath, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecurrenceType, int> get recurrenceType =>
      $composableBuilder(
          column: $table.recurrenceType, builder: (column) => column);

  GeneratedColumn<String> get recurrenceRule => $composableBuilder(
      column: $table.recurrenceRule, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<String> get daysOfWeek => $composableBuilder(
      column: $table.daysOfWeek, builder: (column) => column);

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
      column: $table.dayOfMonth, builder: (column) => column);

  GeneratedColumn<String> get monthPattern => $composableBuilder(
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
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> time = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<NotificationType> notificationType = const Value.absent(),
            Value<String?> soundPath = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<RecurrenceType> recurrenceType = const Value.absent(),
            Value<String?> recurrenceRule = const Value.absent(),
            Value<int> interval = const Value.absent(),
            Value<String?> daysOfWeek = const Value.absent(),
            Value<int?> dayOfMonth = const Value.absent(),
            Value<String?> monthPattern = const Value.absent(),
            Value<int?> endCount = const Value.absent(),
            Value<String?> exceptionDates = const Value.absent(),
            Value<String?> rescheduledDates = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
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
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> description = const Value.absent(),
            required DateTime time,
            required DateTime startDate,
            Value<DateTime?> endDate = const Value.absent(),
            required NotificationType notificationType,
            Value<String?> soundPath = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required RecurrenceType recurrenceType,
            Value<String?> recurrenceRule = const Value.absent(),
            Value<int> interval = const Value.absent(),
            Value<String?> daysOfWeek = const Value.absent(),
            Value<int?> dayOfMonth = const Value.absent(),
            Value<String?> monthPattern = const Value.absent(),
            Value<int?> endCount = const Value.absent(),
            Value<String?> exceptionDates = const Value.absent(),
            Value<String?> rescheduledDates = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
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
            rowid: rowid,
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
  required String id,
  required String scheduleId,
  required DateTime scheduledTime,
  Value<DateTime?> triggeredAt,
  required AlarmStatus status,
  Value<int> snoozeCount,
  required DismissType dismissType,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$HistoryLogsTableUpdateCompanionBuilder = HistoryLogsCompanion
    Function({
  Value<String> id,
  Value<String> scheduleId,
  Value<DateTime> scheduledTime,
  Value<DateTime?> triggeredAt,
  Value<AlarmStatus> status,
  Value<int> snoozeCount,
  Value<DismissType> dismissType,
  Value<String?> notes,
  Value<int> rowid,
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
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scheduleId => $composableBuilder(
      column: $table.scheduleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledTime => $composableBuilder(
      column: $table.scheduledTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get triggeredAt => $composableBuilder(
      column: $table.triggeredAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AlarmStatus, AlarmStatus, int> get status =>
      $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get snoozeCount => $composableBuilder(
      column: $table.snoozeCount, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DismissType, DismissType, int>
      get dismissType => $composableBuilder(
          column: $table.dismissType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
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
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scheduleId => $composableBuilder(
      column: $table.scheduleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledTime => $composableBuilder(
      column: $table.scheduledTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get triggeredAt => $composableBuilder(
      column: $table.triggeredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get snoozeCount => $composableBuilder(
      column: $table.snoozeCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dismissType => $composableBuilder(
      column: $table.dismissType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scheduleId => $composableBuilder(
      column: $table.scheduleId, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledTime => $composableBuilder(
      column: $table.scheduledTime, builder: (column) => column);

  GeneratedColumn<DateTime> get triggeredAt => $composableBuilder(
      column: $table.triggeredAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AlarmStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get snoozeCount => $composableBuilder(
      column: $table.snoozeCount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DismissType, int> get dismissType =>
      $composableBuilder(
          column: $table.dismissType, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
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
            Value<String> id = const Value.absent(),
            Value<String> scheduleId = const Value.absent(),
            Value<DateTime> scheduledTime = const Value.absent(),
            Value<DateTime?> triggeredAt = const Value.absent(),
            Value<AlarmStatus> status = const Value.absent(),
            Value<int> snoozeCount = const Value.absent(),
            Value<DismissType> dismissType = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HistoryLogsCompanion(
            id: id,
            scheduleId: scheduleId,
            scheduledTime: scheduledTime,
            triggeredAt: triggeredAt,
            status: status,
            snoozeCount: snoozeCount,
            dismissType: dismissType,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String scheduleId,
            required DateTime scheduledTime,
            Value<DateTime?> triggeredAt = const Value.absent(),
            required AlarmStatus status,
            Value<int> snoozeCount = const Value.absent(),
            required DismissType dismissType,
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HistoryLogsCompanion.insert(
            id: id,
            scheduleId: scheduleId,
            scheduledTime: scheduledTime,
            triggeredAt: triggeredAt,
            status: status,
            snoozeCount: snoozeCount,
            dismissType: dismissType,
            notes: notes,
            rowid: rowid,
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
