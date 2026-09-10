import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/providers/category_provider.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:titik_waktu/theme/app_colors.dart';
import 'package:titik_waktu/utils/date_format_helper.dart';
import 'package:titik_waktu/utils/recurrence_helper.dart';

class MonthlyCalendarScreen extends ConsumerStatefulWidget {
  const MonthlyCalendarScreen({super.key});

  @override
  ConsumerState<MonthlyCalendarScreen> createState() => _MonthlyCalendarScreenState();
}

class _MonthlyCalendarScreenState extends ConsumerState<MonthlyCalendarScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _focusedMonth = DateTime(now.year, now.month, 1);
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  Color _getScheduleColor(Schedule schedule, Map<int, Category> categoryMap) {
    if (schedule.color != null && schedule.color != 0xFFFFFFFF && schedule.color != 0) {
      return Color(schedule.color!);
    }
    if (schedule.categoryId != null) {
      final cat = categoryMap[schedule.categoryId];
      if (cat != null) {
        return AppColors.parseCategoryColor(cat.colorHex);
      }
    }
    return AppColors.categoryAmber;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final schedulesAsync = ref.watch(scheduleListProvider);
    final categoryMap = ref.watch(categoryMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Jadwal'),
        actions: [
          TextButton.icon(
            onPressed: _goToToday,
            icon: const Icon(Icons.today, size: 18),
            label: const Text('Hari Ini'),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: schedulesAsync.when(
        data: (allSchedules) {
          final activeSchedules = allSchedules.where((s) => s.isActive).toList();

          return Column(
            children: [
              // Month Header with Prev/Next Navigation
              _buildMonthHeader(isDark),

              // Calendar Grid (Weekdays + Days)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildWeekdayLabels(isDark),
                    const SizedBox(height: 6),
                    _buildMonthGrid(activeSchedules, categoryMap, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),

              // Selected Date Schedule List Section
              Expanded(
                child: _buildSelectedDateScheduleList(activeSchedules, categoryMap, isDark),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat jadwal: $err')),
      ),
    );
  }

  Widget _buildMonthHeader(bool isDark) {
    final monthName = DateFormat('MMMM yyyy', 'id_ID').format(_focusedMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Bulan Sebelumnya',
            onPressed: _previousMonth,
          ),
          Text(
            monthName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Bulan Selanjutnya',
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: RecurrenceHelper.dayShortNames.map((name) {
        return Expanded(
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthGrid(
    List<Schedule> activeSchedules,
    Map<int, Category> categoryMap,
    bool isDark,
  ) {
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday = _focusedMonth.weekday; // 1 = Monday .. 7 = Sunday
    final leadingEmptyCount = firstWeekday - 1;

    final totalCells = ((leadingEmptyCount + daysInMonth + 6) ~/ 7) * 7;
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.05,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayNumber = index - leadingEmptyCount + 1;
        final isCurrentMonthDay = dayNumber >= 1 && dayNumber <= daysInMonth;

        if (!isCurrentMonthDay) {
          return const SizedBox();
        }

        final cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
        final isToday = cellDate.year == today.year &&
            cellDate.month == today.month &&
            cellDate.day == today.day;
        final isSelected = cellDate.year == _selectedDate.year &&
            cellDate.month == _selectedDate.month &&
            cellDate.day == _selectedDate.day;

        // Find schedules occurring on this day
        final daySchedules = activeSchedules.where((s) {
          return RecurrenceHelper.isScheduleOccurringOn(s, cellDate);
        }).toList();

        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() => _selectedDate = cellDate);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator)
                  : (isToday
                      ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              border: isToday && !isSelected
                  ? Border.all(
                      color: isDark ? AppColors.amberDarkHighlightBorder : AppColors.amberLightHighlightBorder,
                      width: 1.5,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.black : Colors.white)
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),
                const SizedBox(height: 2),
                // Indicator dots
                if (daySchedules.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: daySchedules.take(3).map((s) {
                      final dotColor = isSelected
                          ? (isDark ? Colors.black87 : Colors.white)
                          : _getScheduleColor(s, categoryMap);
                      return Container(
                        width: 4.5,
                        height: 4.5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  )
                else
                  const SizedBox(height: 4.5),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDateScheduleList(
    List<Schedule> activeSchedules,
    Map<int, Category> categoryMap,
    bool isDark,
  ) {
    final dateFormatted = AppDateFormatter.formatFullDate(_selectedDate);

    final occurringSchedules = <MapEntry<Schedule, OccurrenceInfo>>[];

    for (final schedule in activeSchedules) {
      final occ = RecurrenceHelper.getOccurrenceForDate(schedule, _selectedDate);
      if (occ != null) {
        occurringSchedules.add(MapEntry(schedule, occ));
      }
    }

    // Sort by actual occurrence time
    occurringSchedules.sort((a, b) => a.value.actualDateTime.compareTo(b.value.actualDateTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateFormatted,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '${occurringSchedules.length} Jadwal',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: occurringSchedules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 40,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tidak ada jadwal pada tanggal ini',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: occurringSchedules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = occurringSchedules[index];
                    final schedule = item.key;
                    final occ = item.value;
                    final category = schedule.categoryId != null ? categoryMap[schedule.categoryId] : null;
                    final scheduleColor = _getScheduleColor(schedule, categoryMap);
                    final timeStr = AppDateFormatter.formatTime(occ.actualDateTime);

                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(color: scheduleColor, width: 4),
                          top: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 0.5,
                          ),
                          right: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 0.5,
                          ),
                          bottom: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: ListTile(
                        onTap: () => context.push('/schedule/${schedule.id}'),
                        title: Row(
                          children: [
                            Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                schedule.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            if (category != null) ...[
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.parseCategoryColor(category.colorHex),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (occ.isRescheduled)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.amberDarkHighlightBg : AppColors.amberLightHighlightBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Reschedule',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: Icon(
                          schedule.notificationType == NotificationType.fullAlarm.value
                              ? Icons.alarm
                              : Icons.notifications_none,
                          size: 18,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
