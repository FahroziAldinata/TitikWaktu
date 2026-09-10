import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/providers/category_provider.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:titik_waktu/theme/app_colors.dart';
import 'package:titik_waktu/utils/date_format_helper.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(dailySchedulesProvider);
    final categoryMap = ref.watch(categoryMapProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Titik Waktu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Kalender Bulanan',
            onPressed: () {
              context.push('/calendar');
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Riwayat Aktivitas',
            onPressed: () {
              context.push('/history');
            },
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Kelola Kategori',
            onPressed: () {
              context.push('/categories');
            },
          ),
        ],
      ),
      body: schedulesAsync.when(
        data: (schedules) {
          if (schedules.isEmpty) {
            return _buildEmptyState(context, isDark);
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: schedules.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              final category = schedule.categoryId != null ? categoryMap[schedule.categoryId] : null;
              return _buildScheduleCard(context, schedule, category, isDark);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error: $error', style: theme.textTheme.bodyMedium),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final timeString = AppDateFormatter.formatTimeWithSeconds(_currentTime);
    final dateString = AppDateFormatter.formatFullDate(_currentTime);

    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'TITIK WAKTU',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              timeString,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 42,
                fontWeight: FontWeight.w500,
                letterSpacing: -1.0,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dateString,
              style: TextStyle(
                fontSize: 13,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Tidak ada jadwal untuk hari ini',
              style: TextStyle(
                fontSize: 14,
                color: textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.push('/add'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Jadwal'),
              style: OutlinedButton.styleFrom(
                foregroundColor: textPrimary,
                side: BorderSide(color: borderColor, width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, Schedule schedule, Category? category, bool isDark) {
    final theme = Theme.of(context);

    // Calculate if schedule is within the next 15 minutes
    final scheduleTimeToday = DateTime(
      _currentTime.year,
      _currentTime.month,
      _currentTime.day,
      schedule.time.hour,
      schedule.time.minute,
    );

    final difference = scheduleTimeToday.difference(_currentTime);
    final isUpcomingSoon = schedule.isActive && difference.inSeconds > 0 && difference.inMinutes < 15;

    // Colors based on highlight status
    Color cardBg;
    Color cardBorder;
    Color titleColor;
    Color subtitleColor;

    if (isUpcomingSoon) {
      cardBg = isDark ? AppColors.amberDarkHighlightBg : AppColors.amberLightHighlightBg;
      cardBorder = isDark ? AppColors.amberDarkHighlightBorder : AppColors.amberLightHighlightBorder;
      titleColor = isDark ? AppColors.amberDarkHighlightTitle : AppColors.amberLightHighlightTitle;
      subtitleColor = isDark ? AppColors.amberDarkHighlightSubtitle : AppColors.amberLightHighlightSubtitle;
    } else {
      cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
      cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
      titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
      subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    }

    final timeString = '${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}';

    // Subtitle content: countdown if < 15m, else category name
    String subtitleText;
    if (isUpcomingSoon) {
      final mins = difference.inMinutes;
      subtitleText = mins == 0 ? 'Kurang dari 1 menit lagi' : '$mins menit lagi';
    } else {
      subtitleText = category?.name ?? '';
    }

    // Schedule effective color
    Color? scheduleEffectiveColor;
    if (schedule.color != null && schedule.color != 0xFFFFFFFF && schedule.color != 0) {
      scheduleEffectiveColor = Color(schedule.color!);
    } else if (category != null) {
      scheduleEffectiveColor = AppColors.parseCategoryColor(category.colorHex);
    }

    final categoryDotColor = scheduleEffectiveColor;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: scheduleEffectiveColor ?? (isUpcomingSoon ? cardBorder : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
            width: 4,
          ),
          top: BorderSide(color: cardBorder, width: 0.5),
          right: BorderSide(color: cardBorder, width: 0.5),
          bottom: BorderSide(color: cardBorder, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/schedule/${schedule.id}'),
        child: Row(
          children: [
            // Time Display (38-40px or compact structured)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeString,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                    color: titleColor,
                  ),
                ),
                if (isUpcomingSoon)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitleText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Title & Category metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    schedule.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      // Category Dot (8px diameter) if category exists
                      if (!isUpcomingSoon && category != null && categoryDotColor != null) ...[
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: categoryDotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                      if (!isUpcomingSoon && subtitleText.isNotEmpty)
                        Text(
                          subtitleText,
                          style: TextStyle(
                            fontSize: 11,
                            color: subtitleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Toggle Switch
            Switch(
              value: schedule.isActive,
              activeThumbColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              onChanged: (value) {
                ref.read(scheduleListProvider.notifier).toggleSchedule(schedule.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
