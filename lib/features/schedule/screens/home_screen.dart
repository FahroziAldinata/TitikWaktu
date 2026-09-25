import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/providers/category_provider.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:titik_waktu/theme/app_colors.dart';
import 'package:titik_waktu/widgets/schedule_slidable.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final schedulesAsync = ref.watch(dailySchedulesProvider);
    final categoryMap = ref.watch(categoryMapProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final categoryCountMap = ref.watch(categoryScheduleCountProvider);
    final nextUpcomingAsync = ref.watch(nextUpcomingScheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Titik Waktu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Kalender Bulanan',
            onPressed: () => context.push('/calendar'),
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Riwayat Aktivitas',
            onPressed: () => context.push('/history'),
          ),
        ],
      ),
      body: SlidableAutoCloseBehavior(
        child: CustomScrollView(
          slivers: [
            // Section 1: Hero Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _HeroCard(
                  nextUpcomingAsync: nextUpcomingAsync,
                  categoryMap: categoryMap,
                  currentTime: _currentTime,
                  isDark: isDark,
                ),
              ),
            ),

            // Section 2: Kategori Scroll Horizontal
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: _CategorySection(
                  categoriesAsync: categoriesAsync,
                  categoryCountMap: categoryCountMap,
                  isDark: isDark,
                ),
              ),
            ),

            // Section 3 Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: schedulesAsync.when(
                  data: (schedules) => _sectionHeader(
                    context, isDark, 'Semua Jadwal Hari Ini',
                    count: schedules.length,
                  ),
                  loading: () => _sectionHeader(context, isDark, 'Semua Jadwal Hari Ini'),
                  error: (_, __) => _sectionHeader(context, isDark, 'Semua Jadwal Hari Ini'),
                ),
              ),
            ),

            // Section 3: List / Empty State
            schedulesAsync.when(
              data: (schedules) {
                if (schedules.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _buildSection3Empty(context, isDark),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  sliver: SliverList.separated(
                    itemCount: schedules.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];
                      final category = schedule.categoryId != null
                          ? categoryMap[schedule.categoryId]
                          : null;
                      return ScheduleSlidable(
                        schedule: schedule,
                        child: _buildScheduleCard(context, schedule, category, isDark),
                      );
                    },
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton(
          onPressed: () => context.push('/add'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, bool isDark, String title, {int? count}) {
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        if (count != null && count > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                  .withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSection3Empty(BuildContext context, bool isDark) {
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.5)
              : AppColors.lightSurface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor.withValues(alpha: 0.7), width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Tidak ada jadwal untuk hari ini',
                style: TextStyle(fontSize: 13, color: textMuted),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/add'),
              icon: const Icon(Icons.add, size: 15),
              label: const Text('Tambah', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: textPrimary,
                side: BorderSide(color: borderColor, width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(
      BuildContext context, Schedule schedule, Category? category, bool isDark) {
    final theme = Theme.of(context);

    final scheduleTimeToday = schedule.time != null
        ? DateTime(
            _currentTime.year,
            _currentTime.month,
            _currentTime.day,
            schedule.time!.hour,
            schedule.time!.minute,
          )
        : null;

    final difference = scheduleTimeToday?.difference(_currentTime);
    final isUpcomingSoon = schedule.isActive &&
        difference != null &&
        difference.inSeconds > 0 &&
        difference.inMinutes < 15;

    Color cardBg, cardBorder, titleColor, subtitleColor;

    if (isUpcomingSoon) {
      cardBg = isDark ? AppColors.amberDarkHighlightBg : AppColors.amberLightHighlightBg;
      cardBorder =
          isDark ? AppColors.amberDarkHighlightBorder : AppColors.amberLightHighlightBorder;
      titleColor =
          isDark ? AppColors.amberDarkHighlightTitle : AppColors.amberLightHighlightTitle;
      subtitleColor =
          isDark ? AppColors.amberDarkHighlightSubtitle : AppColors.amberLightHighlightSubtitle;
    } else if (!schedule.isActive) {
      cardBg = isDark
          ? AppColors.darkSurface.withValues(alpha: 0.5)
          : AppColors.lightSurface.withValues(alpha: 0.7);
      cardBorder = isDark
          ? AppColors.darkBorder.withValues(alpha: 0.5)
          : AppColors.lightBorder.withValues(alpha: 0.6);
      titleColor = isDark
          ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
          : AppColors.lightTextSecondary.withValues(alpha: 0.7);
      subtitleColor = isDark
          ? AppColors.darkTextSecondary.withValues(alpha: 0.45)
          : AppColors.lightTextSecondary.withValues(alpha: 0.55);
    } else {
      cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
      cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
      titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
      subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    }

    final timeString = schedule.time != null
        ? '${schedule.time!.hour.toString().padLeft(2, '0')}:${schedule.time!.minute.toString().padLeft(2, '0')}'
        : '--:--';

    String subtitleText;
    if (isUpcomingSoon) {
      final mins = difference.inMinutes;
      subtitleText = mins == 0 ? 'Kurang dari 1 menit lagi' : '$mins menit lagi';
    } else if (!schedule.isActive) {
      subtitleText = category != null ? '${category.name} • Nonaktif' : 'Nonaktif';
    } else {
      subtitleText = category?.name ?? '';
    }

    Color? scheduleEffectiveColor;
    if (schedule.color != null && schedule.color != 0xFFFFFFFF && schedule.color != 0) {
      scheduleEffectiveColor = Color(schedule.color!);
    } else if (category != null) {
      scheduleEffectiveColor = AppColors.parseCategoryColor(category.colorHex);
    }
    if (!schedule.isActive && scheduleEffectiveColor != null) {
      scheduleEffectiveColor = scheduleEffectiveColor.withValues(alpha: 0.35);
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (scheduleEffectiveColor != null)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: scheduleEffectiveColor),
            ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push('/schedule/${schedule.id}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  if (schedule.time != null)
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
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.amber.withOpacity(0.12) : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark ? Colors.amber.withOpacity(0.3) : Colors.amber.shade200,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        'Waktu belum diatur',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.amber.shade300 : Colors.amber.shade800,
                        ),
                      ),
                    ),
                  const SizedBox(width: 16),
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
                            if (!isUpcomingSoon &&
                                category != null &&
                                scheduleEffectiveColor != null) ...[
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: scheduleEffectiveColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                            if (!isUpcomingSoon && subtitleText.isNotEmpty)
                              Text(
                                subtitleText,
                                style: TextStyle(fontSize: 11, color: subtitleColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: schedule.isActive,
                    activeThumbColor: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    onChanged: (value) {
                      ref.read(scheduleListProvider.notifier).toggleSchedule(schedule.id);
                    },
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

// Hero Card Widget
class _HeroCard extends StatelessWidget {
  final AsyncValue<({Schedule schedule, DateTime occurrenceTime})?> nextUpcomingAsync;
  final Map<int, Category> categoryMap;
  final DateTime currentTime;
  final bool isDark;

  const _HeroCard({
    required this.nextUpcomingAsync,
    required this.categoryMap,
    required this.currentTime,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF1C1C1A);
    const cardBorder = Color(0xFF2E2E2B);

    final nearest = nextUpcomingAsync.valueOrNull;

    return GestureDetector(
      onTap: nearest != null
          ? () => context.push('/schedule/${nearest.schedule.id}')
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder, width: 0.5),
        ),
        child: nextUpcomingAsync.when(
          data: (n) => n == null ? _buildEmpty() : _buildContent(context, n.schedule, n.occurrenceTime),
          loading: () => _buildEmpty(),
          error: (_, __) => _buildEmpty(),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'JADWAL BERIKUTNYA',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tidak ada jadwal mendatang',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, Schedule schedule, DateTime occurrenceTime) {
    final category = schedule.categoryId != null ? categoryMap[schedule.categoryId] : null;

    final now = currentTime;
    final today = DateTime(now.year, now.month, now.day);
    final occDay = DateTime(occurrenceTime.year, occurrenceTime.month, occurrenceTime.day);
    final diff = occurrenceTime.difference(now);

    String topLabel;
    if (occDay.isAtSameMomentAs(today)) {
      if (diff.inMinutes < 1) {
        topLabel = 'Hari ini · Kurang dari 1 menit lagi';
      } else if (diff.inHours < 1) {
        topLabel = 'Hari ini · ${diff.inMinutes} menit lagi';
      } else {
        final h = diff.inHours;
        final m = diff.inMinutes % 60;
        topLabel = m > 0 ? 'Hari ini · ${h}j ${m}m lagi' : 'Hari ini · $h jam lagi';
      }
    } else {
      final dayDiff = occDay.difference(today).inDays;
      String dayLabel;
      if (dayDiff == 1) {
        dayLabel = 'Besok';
      } else if (dayDiff <= 6) {
        dayLabel = DateFormat('EEEE', 'id').format(occurrenceTime);
      } else {
        dayLabel = DateFormat('d MMM', 'id').format(occurrenceTime);
      }
      topLabel = '$dayLabel · ${DateFormat('HH:mm').format(occurrenceTime)}';
    }

    final timeString = schedule.time != null
        ? '${schedule.time!.hour.toString().padLeft(2, '0')}:${schedule.time!.minute.toString().padLeft(2, '0')}'
        : '--:--';

    Color? catColor;
    if (category != null) {
      catColor = AppColors.parseCategoryColor(category.colorHex);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          topLabel.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          timeString,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w300,
            letterSpacing: -2,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (catColor != null) ...[
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
              ),
            ],
            Expanded(
              child: Text(
                schedule.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ],
    );
  }
}

// Category Section Widget
class _CategorySection extends StatelessWidget {
  final AsyncValue<List<Category>> categoriesAsync;
  final Map<int, int> categoryCountMap;
  final bool isDark;

  const _CategorySection({
    required this.categoriesAsync,
    required this.categoryCountMap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text(
            'Kategori',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ),
        categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) {
              return _buildCategoryEmpty(context);
            }
            final cardWidth = (MediaQuery.of(context).size.width - 40) / 2.15;
            return SizedBox(
              height: 136,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final count = categoryCountMap[cat.id] ?? 0;
                  return _CategoryCard(
                    category: cat,
                    scheduleCount: count,
                    isDark: isDark,
                    width: cardWidth,
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 136,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox(height: 136),
        ),
      ],
    );
  }

  Widget _buildCategoryEmpty(BuildContext context) {
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.5)
              : AppColors.lightSurface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor.withValues(alpha: 0.7), width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Belum ada kategori',
                style: TextStyle(fontSize: 13, color: textMuted),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/categories'),
              icon: const Icon(Icons.add, size: 15),
              label: const Text('Buat', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: textPrimary,
                side: BorderSide(color: borderColor, width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final int scheduleCount;
  final bool isDark;
  final double width;

  const _CategoryCard({
    required this.category,
    required this.scheduleCount,
    required this.isDark,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.parseCategoryColor(category.colorHex);
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final hasCover = category.coverImageUri != null &&
        category.coverImageUri!.isNotEmpty &&
        File(category.coverImageUri!).existsSync();

    return GestureDetector(
      onTap: () => context.push('/categories/${category.id}'),
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorder, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top 50%: Cover image or solid color fallback with gradient fade
            Expanded(
              flex: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasCover)
                    Image.file(
                      File(category.coverImageUri!),
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      color: catColor.withOpacity(0.35),
                      child: Center(
                        child: Icon(
                          Icons.folder_outlined,
                          size: 26,
                          color: catColor,
                        ),
                      ),
                    ),
                  // Gradient fade to card background
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            cardBg.withOpacity(0.8),
                            cardBg,
                          ],
                          stops: const [0.4, 0.85, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom 50%: Name and schedule count
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text(
                        '$scheduleCount jadwal',
                        style: TextStyle(fontSize: 11, color: textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
