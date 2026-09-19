import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/providers/bulk_schedule_provider.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:titik_waktu/theme/app_colors.dart';
import 'package:titik_waktu/utils/date_format_helper.dart';

class BulkTimeSetterScreen extends ConsumerWidget {
  final Category category;

  const BulkTimeSetterScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bulkState = ref.watch(bulkScheduleProvider);
    final notifier = ref.read(bulkScheduleProvider.notifier);
    final sortedDates = notifier.sortedDates;
    final catColor = AppColors.parseCategoryColor(category.colorHex);
    final count = sortedDates.length;
    final allSet = bulkState.allTimesSet;

    return Scaffold(
      appBar: AppBar(
        title: Text('Set Jam — ${category.name}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Text(
              'Tap baris untuk memilih jam. Semua baris harus terisi sebelum menyimpan.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── List tanggal + picker jam ───────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: sortedDates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final time = bulkState.timeMap[date];
                final dateStr = AppDateFormatter.formatFullDate(date);
                final hasTime = time != null;
                final timeStr = hasTime
                    ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                    : '--:--';

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _pickTime(context, ref, date, time),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasTime
                              ? catColor.withValues(alpha: 0.45)
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Color bar
                          Container(
                            width: 4,
                            height: 38,
                            decoration: BoxDecoration(
                              color: hasTime
                                  ? catColor
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Date + hint
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateStr,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (!hasTime) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tap untuk set jam',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Time display
                          Text(
                            timeStr,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: hasTime
                                  ? (isDark
                                      ? AppColors.amberDarkIndicator
                                      : AppColors.amberLightIndicator)
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status icon
                          Icon(
                            hasTime
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 18,
                            color: hasTime
                                ? AppColors.statusSuccess
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Progress indicator ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: count == 0
                          ? 0
                          : bulkState.timeMap.values
                                  .where((t) => t != null)
                                  .length /
                              count,
                      backgroundColor:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      valueColor: AlwaysStoppedAnimation(catColor),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${bulkState.timeMap.values.where((t) => t != null).length}/$count',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Tombol Simpan ──────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (allSet && !bulkState.isSaving)
                      ? () => _saveBatch(context, ref)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: catColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    disabledBackgroundColor:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    disabledForegroundColor: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  child: bulkState.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          allSet
                              ? 'Simpan Semua ($count Jadwal)'
                              : 'Isi semua jam dulu',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    TimeOfDay? current,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(bulkScheduleProvider.notifier).setTime(date, picked);
    }
  }

  Future<void> _saveBatch(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(bulkScheduleProvider.notifier).saveBatch(category);

      // Refresh kategori schedules di detail screen
      ref.invalidate(categorySchedulesProvider(category.id));
      // Refresh home screen schedule list
      ref.read(scheduleListProvider.notifier).reload();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${ref.read(bulkScheduleProvider).selectedDates.length == 0 ? "Jadwal" : ref.read(bulkScheduleProvider.notifier).sortedDates.length} jadwal berhasil disimpan!',
            ),
            backgroundColor: AppColors.statusSuccess,
            duration: const Duration(seconds: 2),
          ),
        );
        // Pop 2: kembali ke detail screen (lewati calendar picker)
        context.pop(); // pop bulk-time
        context.pop(); // pop calendar
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan jadwal: $e'),
            backgroundColor: AppColors.statusError,
          ),
        );
      }
    }
  }
}
