import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/providers/category_provider.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/theme/app_colors.dart';
import 'package:titik_waktu/utils/date_format_helper.dart';

class ScheduleDetailScreen extends ConsumerWidget {
  final String scheduleId;

  const ScheduleDetailScreen({super.key, required this.scheduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheduleIdInt = int.tryParse(scheduleId) ?? 0;

    final schedulesAsync = ref.watch(scheduleListProvider);
    final categoryMap = ref.watch(categoryMapProvider);

    return schedulesAsync.when(
      data: (schedules) {
        final schedule = schedules.cast<Schedule?>().firstWhere(
              (s) => s?.id == scheduleIdInt,
              orElse: () => null,
            );

        if (schedule == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Jadwal')),
            body: const Center(child: Text('Jadwal tidak ditemukan')),
          );
        }

        final category = schedule.categoryId != null ? categoryMap[schedule.categoryId] : null;
        final timeString =
            '${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}';
        final dateString = schedule.startDate != null
            ? AppDateFormatter.formatFullDate(schedule.startDate!)
            : '-';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Jadwal'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Jadwal',
                onPressed: () {
                  context.push('/edit/$scheduleId');
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Header Waktu Besar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      timeString,
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -1.0,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dateString,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Detail Cards
              _buildDetailItem(
                context,
                title: 'Judul',
                value: schedule.title,
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              if (schedule.description != null && schedule.description!.isNotEmpty) ...[
                _buildDetailItem(
                  context,
                  title: 'Catatan',
                  value: schedule.description!,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
              ],

              _buildDetailItem(
                context,
                title: 'Kategori',
                customWidget: category != null
                    ? Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.parseCategoryColor(category.colorHex),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(category.name, style: theme.textTheme.titleMedium),
                        ],
                      )
                    : Text('Tanpa Kategori', style: theme.textTheme.bodyMedium),
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              _buildDetailItem(
                context,
                title: 'Tipe Notifikasi',
                value: schedule.notificationType == NotificationType.fullAlarm.value
                    ? 'Alarm Penuh'
                    : 'Notifikasi Biasa',
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              _buildDetailItem(
                context,
                title: 'Status',
                value: schedule.isActive ? 'Aktif' : 'Nonaktif',
                isDark: isDark,
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required String title,
    String? value,
    Widget? customWidget,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 6),
          customWidget ??
              Text(
                value ?? '-',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400),
              ),
        ],
      ),
    );
  }
}
