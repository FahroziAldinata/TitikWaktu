import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/providers/bulk_schedule_provider.dart';
import 'package:titik_waktu/theme/app_colors.dart';

class CategoryCalendarPickerScreen extends ConsumerStatefulWidget {
  final Category category;

  const CategoryCalendarPickerScreen({super.key, required this.category});

  @override
  ConsumerState<CategoryCalendarPickerScreen> createState() =>
      _CategoryCalendarPickerScreenState();
}

class _CategoryCalendarPickerScreenState
    extends ConsumerState<CategoryCalendarPickerScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bulkState = ref.watch(bulkScheduleProvider);
    final catColor = AppColors.parseCategoryColor(widget.category.colorHex);
    final count = bulkState.selectedDates.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Tanggal — ${widget.category.name}'),
      ),
      body: Column(
        children: [
          // ── Kalender multi-select ───────────────────────────────────────
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365 * 3)),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Bulan',
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              headerPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: theme.textTheme.labelSmall!.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              weekendStyle: theme.textTheme.labelSmall!.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              // Hari biasa
              defaultTextStyle: theme.textTheme.bodyMedium!.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              // Hari ini: outline warna kategori
              todayDecoration: BoxDecoration(
                border: Border.all(color: catColor, width: 1.5),
                shape: BoxShape.circle,
              ),
              todayTextStyle: theme.textTheme.bodyMedium!.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w600,
              ),
              // Terpilih: solid warna kategori
              selectedDecoration: BoxDecoration(
                color: catColor,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              markerDecoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            ),
            selectedDayPredicate: (day) {
              final normalized = DateTime(day.year, day.month, day.day);
              return bulkState.selectedDates.contains(normalized);
            },
            onDaySelected: (selectedDay, focusedDay) {
              ref
                  .read(bulkScheduleProvider.notifier)
                  .toggleDate(selectedDay);
              setState(() => _focusedDay = focusedDay);
            },
            onPageChanged: (focusedDay) {
              setState(() => _focusedDay = focusedDay);
            },
          ),

          const Divider(height: 1),

          // ── Toggle tipe notifikasi ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                const SizedBox(width: 8),
                Text('Tipe Notifikasi', style: theme.textTheme.bodyMedium),
                const Spacer(),
                SegmentedButton<NotificationType>(
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: catColor,
                    selectedForegroundColor: Colors.white,
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  segments: const [
                    ButtonSegment(
                      value: NotificationType.notification,
                      label: Text('Notifikasi'),
                      icon: Icon(Icons.notifications, size: 14),
                    ),
                    ButtonSegment(
                      value: NotificationType.fullAlarm,
                      label: Text('Alarm Penuh'),
                      icon: Icon(Icons.alarm, size: 14),
                    ),
                  ],
                  selected: {bulkState.notificationType},
                  onSelectionChanged: (selected) {
                    ref
                        .read(bulkScheduleProvider.notifier)
                        .setNotificationType(selected.first);
                  },
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── Bottom bar: counter + tombol lanjut ────────────────────────
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          count == 0
                              ? 'Belum ada tanggal dipilih'
                              : '$count tanggal dipilih',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: count > 0
                                ? catColor
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                            fontWeight: count > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (count > 0)
                          Text(
                            'Tap tanggal lagi untuk batalkan pilihan',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: count == 0
                        ? null
                        : () => context.push(
                              '/categories/${widget.category.id}/bulk-time',
                              extra: widget.category,
                            ),
                    icon: const Icon(Icons.schedule, size: 18),
                    label: const Text('Lanjut set jam'),
                    style: FilledButton.styleFrom(
                      backgroundColor: catColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      disabledForegroundColor:
                          isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
