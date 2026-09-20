import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:titik_waktu/theme/app_colors.dart';

/// Widget wrapper Slidable untuk semua kartu jadwal individual.
///
/// Interaksi:
/// - Geser ke KIRI (reveal di kanan / endActionPane):
///   Action **Edit** — warna netral, icon pensil, tap untuk navigasi ke form edit jadwal.
/// - Geser ke KANAN (reveal di kiri / startActionPane):
///   Action **Hapus** — warna `AppColors.statusError`, icon tempat sampah, tap memunculkan dialog konfirmasi.
class ScheduleSlidable extends ConsumerWidget {
  final Schedule schedule;
  final Widget child;
  final VoidCallback? onDeleted;
  final VoidCallback? onEdit;
  final Future<void> Function(Schedule schedule)? onDelete;
  final BorderRadius borderRadius;

  const ScheduleSlidable({
    super.key,
    required this.schedule,
    required this.child,
    this.onDeleted,
    this.onEdit,
    this.onDelete,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Warna netral untuk action Edit (bukan warna alarm/kategori)
    final editBgColor = isDark ? const Color(0xFF2E2C28) : const Color(0xFFE2E0DB);
    final editFgColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Slidable(
        key: ValueKey(schedule.id),
        // Geser ke KANAN -> Reveal Action HAPUS di KIRI
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.26,
          children: [
            SlidableAction(
              onPressed: (ctx) => _showDeleteConfirmation(context, ref),
              backgroundColor: AppColors.statusError,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: 'Hapus',
              borderRadius: BorderRadius.horizontal(left: borderRadius.topLeft),
            ),
          ],
        ),
        // Geser ke KIRI -> Reveal Action EDIT di KANAN
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.26,
          children: [
            SlidableAction(
              onPressed: (ctx) {
                if (onEdit != null) {
                  onEdit!();
                } else {
                  context.push('/edit/${schedule.id}');
                }
              },
              backgroundColor: editBgColor,
              foregroundColor: editFgColor,
              icon: Icons.edit_outlined,
              label: 'Edit',
              borderRadius: BorderRadius.horizontal(right: borderRadius.topRight),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: const Text('Jadwal akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.statusError),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      if (onDelete != null) {
        await onDelete!(schedule);
      } else {
        await ref.read(scheduleListProvider.notifier).deleteSchedule(schedule.id);
      }
      onDeleted?.call();
    }
  }
}
