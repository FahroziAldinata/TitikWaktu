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

class ScheduleDetailScreen extends ConsumerStatefulWidget {
  final String scheduleId;

  const ScheduleDetailScreen({super.key, required this.scheduleId});

  @override
  ConsumerState<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends ConsumerState<ScheduleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheduleIdInt = int.tryParse(widget.scheduleId) ?? 0;

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
        Color? scheduleEffectiveColor;
        if (schedule.color != null && schedule.color != 0xFFFFFFFF && schedule.color != 0) {
          scheduleEffectiveColor = Color(schedule.color!);
        } else if (category != null) {
          scheduleEffectiveColor = AppColors.parseCategoryColor(category.colorHex);
        }

        final timeString =
            '${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}';
        final dateString = schedule.startDate != null
            ? AppDateFormatter.formatFullDate(schedule.startDate!)
            : '-';

        final recurrenceSentence = RecurrenceHelper.formatHumanReadable(
          recurrenceType: RecurrenceType.fromValue(schedule.recurrenceType),
          rruleString: schedule.recurrenceRule,
          startDate: schedule.startDate,
        );

        final occurrences = RecurrenceHelper.getUpcomingOccurrences(schedule, limit: 7);
        final exceptionDates = RecurrenceHelper.parseExceptionDates(schedule.exceptionDates).toList()..sort();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Jadwal'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Jadwal Utama',
                onPressed: () {
                  context.push('/edit/${widget.scheduleId}');
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Header Waktu Besar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    left: BorderSide(
                      color: scheduleEffectiveColor ?? (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: 5,
                    ),
                    top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
                    right: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
                    bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      timeString,
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1.0,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      schedule.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mulai: $dateString',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.amberDarkHighlightBg : AppColors.amberLightHighlightBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.amberDarkHighlightBorder : AppColors.amberLightHighlightBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.autorenew_rounded,
                            size: 14,
                            color: isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            recurrenceSentence,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.amberDarkHighlightTitle : AppColors.amberLightHighlightTitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Detail Item Cards (Grid or Rows)
              if (schedule.description != null && schedule.description!.isNotEmpty) ...[
                _buildDetailItem(
                  context,
                  title: 'Catatan',
                  value: schedule.description!,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
              ],

              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      title: 'Kategori',
                      customWidget: category != null
                          ? Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.parseCategoryColor(category.colorHex),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    category.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                          : Text('Tanpa Kategori', style: theme.textTheme.bodySmall),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      title: 'Tipe Notifikasi',
                      value: schedule.notificationType == NotificationType.fullAlarm.value
                          ? 'Alarm Penuh'
                          : 'Notifikasi',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SECTION: JADWAL MENDATANG (UPCOMING OCCURRENCES)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'JADWAL MENDATANG',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    '${occurrences.length} jadwal terdekat',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (occurrences.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 0.5,
                    ),
                  ),
                  child: const Center(
                    child: Text('Tidak ada jadwal mendatang yang aktif.', style: TextStyle(fontSize: 13)),
                  ),
                )
              else
                ...occurrences.map((occ) => _buildOccurrenceCard(context, schedule, occ, isDark)),

              const SizedBox(height: 24),

              // SECTION: TANGGAL PENGECUALIAN (EXCEPTION DATES)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TANGGAL PENGECUALIAN (DILEWATI)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tambah', style: TextStyle(fontSize: 12)),
                    onPressed: () => _addExceptionDatePicker(context, schedule),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              if (exceptionDates.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Belum ada tanggal yang dikecualikan.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...exceptionDates.map((dateStr) {
                  final dt = RecurrenceHelper.parseDateKey(dateStr);
                  final formatted = dt != null ? AppDateFormatter.formatFullDate(dt) : dateStr;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event_busy, size: 18, color: Colors.orangeAccent),
                            const SizedBox(width: 10),
                            Text(
                              formatted,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          tooltip: 'Hapus Pengecualian',
                          onPressed: () {
                            ref
                                .read(scheduleListProvider.notifier)
                                .removeExceptionDate(schedule.id, dateStr);
                          },
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  Widget _buildOccurrenceCard(
    BuildContext context,
    Schedule schedule,
    OccurrenceInfo occ,
    bool isDark,
  ) {
    final timeStr = AppDateFormatter.formatTime(occ.actualDateTime);
    final dateStr = AppDateFormatter.formatFullDate(occ.actualDateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: occ.isRescheduled
              ? (isDark ? AppColors.amberDarkHighlightBorder : AppColors.amberLightHighlightBorder)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: occ.isRescheduled ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              timeStr,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                if (occ.isRescheduled) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.amberDarkHighlightBg : AppColors.amberLightHighlightBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Direschedule dari ${RecurrenceHelper.formatDateKey(occ.originalDate)}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            tooltip: 'Opsi Occurrence',
            onPressed: () => _showOccurrenceOptionsDialog(context, schedule, occ),
          ),
        ],
      ),
    );
  }

  Future<void> _showOccurrenceOptionsDialog(
    BuildContext context,
    Schedule schedule,
    OccurrenceInfo occ,
  ) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Pilihan Jadwal: ${DateFormat('d MMMM yyyy', 'id_ID').format(occ.actualDateTime)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_calendar, color: Colors.amber),
                  title: const Text('Edit hanya jadwal ini (Reschedule)'),
                  subtitle: const Text('Ubah waktu/tanggal khusus untuk hari ini saja'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _rescheduleOccurrence(context, schedule, occ);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.all_inclusive, color: Colors.blueAccent),
                  title: const Text('Edit semua jadwal berulang'),
                  subtitle: const Text('Ubah konfigurasi jadwal utama'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/edit/${schedule.id}');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event_busy, color: Colors.orangeAccent),
                  title: const Text('Lewati jadwal ini'),
                  subtitle: const Text('Tambahkan tanggal ini ke daftar pengecualian'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref
                        .read(scheduleListProvider.notifier)
                        .addExceptionDate(schedule.id, occ.originalDate);
                  },
                ),
                if (occ.isRescheduled)
                  ListTile(
                    leading: const Icon(Icons.restore, color: Colors.green),
                    title: const Text('Kembalikan ke jadwal asal'),
                    subtitle: const Text('Hapus reschedule dan gunakan waktu bawaan'),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await ref
                          .read(scheduleListProvider.notifier)
                          .resetOccurrence(schedule.id, occ.originalDate);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _rescheduleOccurrence(
    BuildContext context,
    Schedule schedule,
    OccurrenceInfo occ,
  ) async {
    // 1. Pick new Date
    final newDate = await showDatePicker(
      context: context,
      initialDate: occ.actualDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'PILIH TANGGAL BARU UNTUK JADWAL INI',
    );
    if (newDate == null || !mounted) return;

    // 2. Pick new Time
    final newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: occ.actualDateTime.hour, minute: occ.actualDateTime.minute),
      helpText: 'PILIH JAM BARU UNTUK JADWAL INI',
    );
    if (newTime == null || !mounted) return;

    final newDateTime = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      newTime.hour,
      newTime.minute,
    );

    await ref.read(scheduleListProvider.notifier).rescheduleSingleOccurrence(
          schedule.id,
          originalDate: occ.originalDate,
          newDateTime: newDateTime,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jadwal berhasil dipindah ke ${AppDateFormatter.formatFullDate(newDateTime)} pukul ${AppDateFormatter.formatTime(newDateTime)}',
          ),
        ),
      );
    }
  }

  Future<void> _addExceptionDatePicker(BuildContext context, Schedule schedule) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'PILIH TANGGAL PENGECUALIAN',
    );

    if (picked != null && mounted) {
      await ref.read(scheduleListProvider.notifier).addExceptionDate(schedule.id, picked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tanggal ${AppDateFormatter.formatFullDate(picked)} ditambahkan ke pengecualian.',
            ),
          ),
        );
      }
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          const SizedBox(height: 4),
          customWidget ??
              Text(
                value ?? '-',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
        ],
      ),
    );
  }
}
