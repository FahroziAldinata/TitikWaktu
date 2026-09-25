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
        title: Text('Review & Simpan — ${category.name}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(38),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Text(
              'Tahap Akhir: Periksa kembali tanggal, jam, dan judul jadwal sebelum disimpan.',
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
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final time = bulkState.timeMap[date];
                final dateStr = AppDateFormatter.formatFullDate(date);
                final hasTime = time != null;
                final timeStr = hasTime
                    ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                    : '--:--';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasTime
                          ? catColor.withValues(alpha: 0.45)
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris tanggal & picker jam
                      InkWell(
                        onTap: () => _pickTime(context, ref, date, time),
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            // Color bar
                            Container(
                              width: 4,
                              height: 36,
                              decoration: BoxDecoration(
                                color: hasTime
                                    ? catColor
                                    : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dateStr,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    hasTime ? 'Tap untuk ubah jam' : 'Tap untuk set jam',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Time button
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: hasTime
                                    ? catColor.withValues(alpha: 0.15)
                                    : (isDark
                                        ? AppColors.darkBackground
                                        : AppColors.lightBackground),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: hasTime
                                      ? catColor.withValues(alpha: 0.5)
                                      : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color: hasTime
                                        ? (isDark
                                            ? AppColors.amberDarkIndicator
                                            : AppColors.amberLightIndicator)
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    timeStr,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'monospace',
                                      color: hasTime
                                          ? (isDark
                                              ? AppColors.amberDarkIndicator
                                              : AppColors.amberLightIndicator)
                                          : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Field Nama Jadwal (Opsional)
                      TextFormField(
                        key: ValueKey('title_${date.millisecondsSinceEpoch}'),
                        initialValue: bulkState.titleMap[date] ?? '',
                        decoration: InputDecoration(
                          hintText: 'Nama jadwal (opsional, default: ${category.name})',
                          hintStyle: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                                : AppColors.lightTextSecondary.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                              width: 0.8,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                              width: 0.8,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: catColor,
                              width: 1.2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.label_outline_rounded,
                            size: 16,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                        ),
                        onChanged: (val) {
                          ref
                              .read(bulkScheduleProvider.notifier)
                              .setTitle(date, val);
                        },
                      ),
                    ],
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
                  onPressed: (count > 0 && !bulkState.isSaving)
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
                          'Simpan Semua ($count Jadwal)',
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
