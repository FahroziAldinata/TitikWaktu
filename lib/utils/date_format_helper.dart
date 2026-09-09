import 'package:intl/intl.dart';

class AppDateFormatter {
  AppDateFormatter._();

  static const List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Format date as: "Senin, 9 September 2026"
  static String formatFullDate(DateTime date) {
    try {
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      try {
        return DateFormat('EEEE, d MMMM yyyy', 'id').format(date);
      } catch (_) {
        final dayName = _days[date.weekday - 1];
        final monthName = _months[date.month - 1];
        return '$dayName, ${date.day} $monthName ${date.year}';
      }
    }
  }

  /// Format time as: "12:30"
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Format time with seconds as: "12:30:45"
  static String formatTimeWithSeconds(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }
}
