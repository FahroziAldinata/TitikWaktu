import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rrule/rrule.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/utils/date_format_helper.dart';

class OccurrenceInfo {
  final DateTime originalDate;
  final DateTime actualDateTime;
  final bool isRescheduled;
  final bool isException;

  OccurrenceInfo({
    required this.originalDate,
    required this.actualDateTime,
    this.isRescheduled = false,
    this.isException = false,
  });

  String get originalDateStr => RecurrenceHelper.formatDateKey(originalDate);
  String get actualDateStr => RecurrenceHelper.formatDateKey(actualDateTime);
}

enum MonthlyPatternType {
  dayOfMonth, // e.g. every month on the 15th
  nthWeekday, // e.g. every month on the 1st Monday
}

class RecurrenceHelper {
  RecurrenceHelper._();

  static const List<String> dayShortNames = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static const List<String> dayFullNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> rruleWeekdays = [
    'MO',
    'TU',
    'WE',
    'TH',
    'FR',
    'SA',
    'SU',
  ];

  static const List<String> ordinalNames = [
    'pertama',
    'kedua',
    'ketiga',
    'keempat',
    'terakhir',
  ];

  static String formatDateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime? parseDateKey(String key) {
    try {
      final parts = key.trim().split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    } catch (_) {}
    return null;
  }

  /// Parse exception dates string into a Set of date strings (YYYY-MM-DD)
  static Set<String> parseExceptionDates(String? raw) {
    if (raw == null || raw.trim().isEmpty) return <String>{};
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  /// Format a Set of date strings (YYYY-MM-DD) to DB string
  static String? formatExceptionDates(Set<String> dates) {
    if (dates.isEmpty) return null;
    final sorted = dates.toList()..sort();
    return sorted.join(', ');
  }

  /// Add an exception date to raw string
  static String? addExceptionDate(String? raw, DateTime date) {
    final set = parseExceptionDates(raw);
    set.add(formatDateKey(date));
    return formatExceptionDates(set);
  }

  /// Remove an exception date from raw string
  static String? removeExceptionDate(String? raw, String dateKey) {
    final set = parseExceptionDates(raw);
    set.remove(dateKey.trim());
    return formatExceptionDates(set);
  }

  /// Parse rescheduledDates JSON map: {"2026-09-10": "2026-09-11T14:30:00"}
  static Map<String, DateTime> parseRescheduledDates(String? raw) {
    if (raw == null || raw.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final result = <String, DateTime>{};
        decoded.forEach((key, value) {
          if (value is String) {
            final dt = DateTime.tryParse(value);
            if (dt != null) {
              result[key.toString()] = dt;
            }
          }
        });
        return result;
      }
    } catch (_) {}
    return {};
  }

  /// Format rescheduledDates map to JSON string
  static String? formatRescheduledDates(Map<String, DateTime> map) {
    if (map.isEmpty) return null;
    final strMap = <String, String>{};
    map.forEach((key, dt) {
      strMap[key] = dt.toIso8601String();
    });
    return jsonEncode(strMap);
  }

  /// Add or update a rescheduled occurrence
  static String? addRescheduledOccurrence(
    String? raw, {
    required DateTime originalDate,
    required DateTime newDateTime,
  }) {
    final map = parseRescheduledDates(raw);
    map[formatDateKey(originalDate)] = newDateTime;
    return formatRescheduledDates(map);
  }

  /// Remove rescheduled occurrence
  static String? removeRescheduledOccurrence(String? raw, String originalDateKey) {
    final map = parseRescheduledDates(raw);
    map.remove(originalDateKey.trim());
    return formatRescheduledDates(map);
  }

  /// Build RRULE RFC 5545 string
  static String? buildRruleString({
    required RecurrenceType type,
    int interval = 1,
    List<int>? selectedWeekdays, // 1 for Monday .. 7 for Sunday
    MonthlyPatternType monthlyPattern = MonthlyPatternType.dayOfMonth,
    int? dayOfMonth,
    int nthWeekdayOrdinal = 1, // 1..4, or -1 for last
    int nthWeekday = 1, // 1 for Monday .. 7 for Sunday
  }) {
    final validInterval = interval > 0 ? interval : 1;

    switch (type) {
      case RecurrenceType.once:
      case RecurrenceType.none:
        return null;

      case RecurrenceType.daily:
        return 'RRULE:FREQ=DAILY;INTERVAL=$validInterval';

      case RecurrenceType.weekly:
        final days = selectedWeekdays != null && selectedWeekdays.isNotEmpty
            ? (selectedWeekdays..sort()).map((d) => rruleWeekdays[d - 1]).join(',')
            : 'MO,TU,WE,TH,FR,SA,SU';
        return 'RRULE:FREQ=WEEKLY;INTERVAL=$validInterval;BYDAY=$days';

      case RecurrenceType.monthly:
        if (monthlyPattern == MonthlyPatternType.dayOfMonth) {
          final dom = dayOfMonth != null && dayOfMonth >= 1 && dayOfMonth <= 31
              ? dayOfMonth
              : 1;
          return 'RRULE:FREQ=MONTHLY;INTERVAL=$validInterval;BYMONTHDAY=$dom';
        } else {
          final weekdayStr = rruleWeekdays[(nthWeekday - 1).clamp(0, 6)];
          final posStr = nthWeekdayOrdinal == -1 ? '-1' : '$nthWeekdayOrdinal';
          return 'RRULE:FREQ=MONTHLY;INTERVAL=$validInterval;BYDAY=$posStr$weekdayStr';
        }

      case RecurrenceType.customInterval:
        return 'RRULE:FREQ=DAILY;INTERVAL=$validInterval';

      case RecurrenceType.yearly:
        return 'RRULE:FREQ=YEARLY;INTERVAL=$validInterval';
    }
  }

  /// Convert RRULE or schedule settings into a human-readable Indonesian string
  static String formatHumanReadable({
    required RecurrenceType recurrenceType,
    String? rruleString,
    DateTime? startDate,
    int interval = 1,
    List<int>? selectedWeekdays,
    MonthlyPatternType monthlyPattern = MonthlyPatternType.dayOfMonth,
    int? dayOfMonth,
    int nthOrdinal = 1,
    int nthWeekday = 1,
  }) {
    if (recurrenceType == RecurrenceType.once || recurrenceType == RecurrenceType.none) {
      if (startDate != null) {
        return 'Sekali pada ${AppDateFormatter.formatFullDate(startDate)}';
      }
      return 'Hanya sekali';
    }

    if (rruleString != null && rruleString.trim().isNotEmpty) {
      try {
        final rrule = RecurrenceRule.fromString(rruleString);
        final freq = rrule.frequency;
        final iv = rrule.interval ?? 1;

        if (freq == Frequency.daily) {
          return iv == 1 ? 'Setiap hari' : 'Setiap $iv hari';
        }

        if (freq == Frequency.weekly) {
          final byDay = rrule.byWeekDays;
          if (byDay.isNotEmpty) {
            final dayNames = byDay.map((d) {
              final idx = d.day - 1; // 1=Monday -> index 0
              return dayFullNames[idx.clamp(0, 6)];
            }).toList();
            final daysText = dayNames.join(', ');
            final ivText = iv == 1 ? 'Setiap minggu' : 'Setiap $iv minggu';
            return '$ivText pada $daysText';
          }
          return iv == 1 ? 'Setiap minggu' : 'Setiap $iv minggu';
        }

        if (freq == Frequency.monthly) {
          final ivText = iv == 1 ? 'Setiap bulan' : 'Setiap $iv bulan';
          if (rrule.byMonthDays.isNotEmpty) {
            final dom = rrule.byMonthDays.first;
            return '$ivText pada tanggal $dom';
          }
          if (rrule.byWeekDays.isNotEmpty) {
            final byWeekDay = rrule.byWeekDays.first;
            final dayIndex = byWeekDay.day - 1;
            final dayName = dayFullNames[dayIndex.clamp(0, 6)];
            final pos = byWeekDay.occurrence;
            String posName = 'pertama';
            if (pos == 1) posName = 'pertama';
            else if (pos == 2) posName = 'kedua';
            else if (pos == 3) posName = 'ketiga';
            else if (pos == 4) posName = 'keempat';
            else if (pos == -1) posName = 'terakhir';
            return '$ivText pada $dayName $posName';
          }
          return ivText;
        }

        if (freq == Frequency.yearly) {
          return iv == 1 ? 'Setiap tahun' : 'Setiap $iv tahun';
        }
      } catch (_) {}
    }

    // Fallback from parameters
    final validIv = interval > 0 ? interval : 1;
    switch (recurrenceType) {
      case RecurrenceType.daily:
        return validIv == 1 ? 'Setiap hari' : 'Setiap $validIv hari';
      case RecurrenceType.weekly:
        if (selectedWeekdays != null && selectedWeekdays.isNotEmpty) {
          final dayNames = (selectedWeekdays..sort()).map((d) => dayFullNames[d - 1]).join(', ');
          final ivText = validIv == 1 ? 'Setiap minggu' : 'Setiap $validIv minggu';
          return '$ivText pada $dayNames';
        }
        return validIv == 1 ? 'Setiap minggu' : 'Setiap $validIv minggu';
      case RecurrenceType.monthly:
        final ivText = validIv == 1 ? 'Setiap bulan' : 'Setiap $validIv bulan';
        if (monthlyPattern == MonthlyPatternType.dayOfMonth) {
          final dom = dayOfMonth ?? (startDate?.day ?? 1);
          return '$ivText pada tanggal $dom';
        } else {
          final dayName = dayFullNames[(nthWeekday - 1).clamp(0, 6)];
          String posName = 'pertama';
          if (nthOrdinal == 1) posName = 'pertama';
          else if (nthOrdinal == 2) posName = 'kedua';
          else if (nthOrdinal == 3) posName = 'ketiga';
          else if (nthOrdinal == 4) posName = 'keempat';
          else if (nthOrdinal == -1) posName = 'terakhir';
          return '$ivText pada $dayName $posName';
        }
      case RecurrenceType.customInterval:
        return 'Setiap $validIv hari';
      case RecurrenceType.yearly:
        return validIv == 1 ? 'Setiap tahun' : 'Setiap $validIv tahun';
      case RecurrenceType.once:
      case RecurrenceType.none:
        return 'Hanya sekali';
    }
  }

  /// Compute the next occurrences for a given schedule, factoring in RRULE, exceptionDates, and rescheduledDates.
  static List<OccurrenceInfo> getUpcomingOccurrences(
    Schedule schedule, {
    int limit = 10,
    DateTime? fromDate,
  }) {
    if (!schedule.isActive || schedule.startDate == null) {
      return [];
    }

    final startDay = DateTime(
      schedule.startDate!.year,
      schedule.startDate!.month,
      schedule.startDate!.day,
    );

    final baseDate = fromDate ?? DateTime.now();
    final today = DateTime(baseDate.year, baseDate.month, baseDate.day);
    final evaluationStart = today.isBefore(startDay) ? startDay : today;

    final exceptionSet = parseExceptionDates(schedule.exceptionDates);
    final rescheduledMap = parseRescheduledDates(schedule.rescheduledDates);

    final results = <OccurrenceInfo>[];

    // Case 1: Single occurrence / Once
    if (schedule.recurrenceRule == null ||
        schedule.recurrenceRule!.trim().isEmpty ||
        schedule.recurrenceType == RecurrenceType.once.value ||
        schedule.recurrenceType == RecurrenceType.none.value) {
      final origKey = formatDateKey(startDay);
      final isException = exceptionSet.contains(origKey);
      final isRescheduled = rescheduledMap.containsKey(origKey);

      DateTime actualDateTime = DateTime(
        startDay.year,
        startDay.month,
        startDay.day,
        schedule.time.hour,
        schedule.time.minute,
      );

      if (isRescheduled) {
        actualDateTime = rescheduledMap[origKey]!;
      }

      if (!isException) {
        results.add(OccurrenceInfo(
          originalDate: startDay,
          actualDateTime: actualDateTime,
          isRescheduled: isRescheduled,
          isException: isException,
        ));
      }
      return results;
    }

    // Case 2: Recurring with RRULE
    try {
      final rrule = RecurrenceRule.fromString(schedule.recurrenceRule!);
      final startUtc = DateTime.utc(
        startDay.year,
        startDay.month,
        startDay.day,
        schedule.time.hour,
        schedule.time.minute,
      );

      // Search up to 2 years ahead or until limit is satisfied
      final searchEndUtc = DateTime.utc(
        evaluationStart.year + 2,
        evaluationStart.month,
        evaluationStart.day,
        23,
        59,
        59,
      );

      final evalStartUtc = DateTime.utc(
        evaluationStart.year,
        evaluationStart.month,
        evaluationStart.day,
        0,
        0,
        0,
      );

      final instances = rrule.getInstances(
        start: startUtc,
        after: evalStartUtc.isBefore(startUtc) ? startUtc : evalStartUtc,
        before: searchEndUtc,
        includeAfter: true,
        includeBefore: true,
      );

      for (final inst in instances) {
        if (results.length >= limit) break;

        final origDate = DateTime(inst.year, inst.month, inst.day);
        final origKey = formatDateKey(origDate);

        final isException = exceptionSet.contains(origKey);
        final isRescheduled = rescheduledMap.containsKey(origKey);

        DateTime actualDt = DateTime(
          origDate.year,
          origDate.month,
          origDate.day,
          schedule.time.hour,
          schedule.time.minute,
        );

        if (isRescheduled) {
          actualDt = rescheduledMap[origKey]!;
        }

        final actualKey = formatDateKey(actualDt);
        final isActualException = exceptionSet.contains(actualKey);

        // If either the original date or rescheduled target date is an exception, skip it
        if (!isException && !isActualException) {
          results.add(OccurrenceInfo(
            originalDate: origDate,
            actualDateTime: actualDt,
            isRescheduled: isRescheduled,
            isException: false,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error getting upcoming occurrences: $e');
    }

    // Sort by actualDateTime
    results.sort((a, b) => a.actualDateTime.compareTo(b.actualDateTime));
    return results.take(limit).toList();
  }
}
