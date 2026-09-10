import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/providers/history_provider.dart';
import 'package:titik_waktu/theme/app_colors.dart';
import 'package:titik_waktu/utils/date_format_helper.dart';

class HistoryLogScreen extends ConsumerStatefulWidget {
  const HistoryLogScreen({super.key});

  @override
  ConsumerState<HistoryLogScreen> createState() => _HistoryLogScreenState();
}

class _HistoryLogScreenState extends ConsumerState<HistoryLogScreen> {
  HistoryActionCategory _selectedFilter = HistoryActionCategory.all;

  List<HistoryLog> _filterLogs(List<HistoryLog> logs) {
    switch (_selectedFilter) {
      case HistoryActionCategory.all:
        return logs;
      case HistoryActionCategory.alarm:
        return logs.where((l) => l.action.startsWith('ALARM_')).toList();
      case HistoryActionCategory.schedule:
        return logs.where((l) => l.action.startsWith('SCHEDULE_')).toList();
      case HistoryActionCategory.snooze:
        return logs.where((l) => l.action.startsWith('ALARM_SNOOZED')).toList();
      case HistoryActionCategory.missed:
        return logs.where((l) => l.action.startsWith('ALARM_MISSED')).toList();
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dt.year, dt.month, dt.day);
    final timeStr = AppDateFormatter.formatTime(dt);

    if (targetDate.isAtSameMomentAs(today)) {
      return 'Hari ini, $timeStr';
    }
    final yesterday = today.subtract(const Duration(days: 1));
    if (targetDate.isAtSameMomentAs(yesterday)) {
      return 'Kemarin, $timeStr';
    }
    return '${dt.day}/${dt.month}/${dt.year}, $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final historyAsync = ref.watch(historyLogListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Aktivitas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Hapus Semua Riwayat',
            onPressed: () => _confirmClearHistory(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip('Semua', HistoryActionCategory.all, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Alarm', HistoryActionCategory.alarm, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Jadwal', HistoryActionCategory.schedule, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Snooze', HistoryActionCategory.snooze, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Terlewat', HistoryActionCategory.missed, isDark),
              ],
            ),
          ),
          const Divider(height: 1),

          // Log List
          Expanded(
            child: historyAsync.when(
              data: (allLogs) {
                final logs = _filterLogs(allLogs);
                if (logs.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return _buildLogItem(context, log, isDark);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Gagal memuat riwayat: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, HistoryActionCategory category, bool isDark) {
    final isSelected = _selectedFilter == category;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? (isDark ? Colors.black : Colors.white)
              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
        ),
      ),
      selected: isSelected,
      selectedColor: isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      side: BorderSide(
        color: isSelected
            ? (isDark ? AppColors.amberDarkHighlightBorder : AppColors.amberLightHighlightBorder)
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        width: 0.5,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = category);
        }
      },
    );
  }

  Widget _buildLogItem(BuildContext context, HistoryLog log, bool isDark) {
    final title = HistoryLogHelper.formatActionTitle(log.action);
    final icon = HistoryLogHelper.getActionIcon(log.action);
    final actionColor = HistoryLogHelper.getActionColor(log.action);
    final timeStr = _formatTimestamp(log.timestamp);

    return Dismissible(
      key: ValueKey(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
      ),
      onDismissed: (_) {
        ref.read(historyRepositoryProvider).deleteLog(log.id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: actionColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: actionColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            size: 48,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada riwayat aktivitas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Riwayat?'),
        content: const Text('Seluruh catatan aktivitas alarm dan jadwal akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(historyRepositoryProvider).clearAllHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Riwayat berhasil dibersihkan.')),
        );
      }
    }
  }
}
