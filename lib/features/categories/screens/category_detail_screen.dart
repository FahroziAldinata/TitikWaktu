import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/providers/bulk_schedule_provider.dart';
import 'package:titik_waktu/providers/category_provider.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:titik_waktu/services/ringtone_service.dart';
import 'package:titik_waktu/theme/app_colors.dart';
import 'package:titik_waktu/utils/date_format_helper.dart';
import 'package:titik_waktu/widgets/category_color_picker_field.dart';
import 'package:titik_waktu/widgets/ringtone_picker_sheet.dart';
import 'package:titik_waktu/widgets/schedule_slidable.dart';

class CategoryDetailScreen extends ConsumerWidget {
  final int categoryId;

  const CategoryDetailScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch category dari stream supaya auto-update setelah edit
    final categoriesAsync = ref.watch(categoryListProvider);
    final schedulesAsync = ref.watch(categorySchedulesProvider(categoryId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return categoriesAsync.when(
      data: (categories) {
        final category = categories.where((c) => c.id == categoryId).firstOrNull;
        if (category == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Kategori')),
            body: const Center(child: Text('Kategori tidak ditemukan')),
          );
        }
        final catColor = AppColors.parseCategoryColor(category.colorHex);
        return _buildScaffold(
          context: context,
          ref: ref,
          category: category,
          catColor: catColor,
          schedulesAsync: schedulesAsync,
          theme: theme,
          isDark: isDark,
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildScaffold({
    required BuildContext context,
    required WidgetRef ref,
    required Category category,
    required Color catColor,
    required AsyncValue<List<Schedule>> schedulesAsync,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                category.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditSheet(context, ref, category);
              } else if (value == 'delete') {
                _showDeleteDialog(context, ref, category);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit Kategori'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: Text('Hapus Kategori',
                      style: TextStyle(color: Colors.redAccent)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: schedulesAsync.when(
        data: (schedules) {
          if (schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 56,
                    color: catColor.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada jadwal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap tombol di bawah untuk tambah banyak jadwal sekaligus',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return SlidableAutoCloseBehavior(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: schedules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final s = schedules[index];
                final dateStr = AppDateFormatter.formatFullDate(s.startDate ?? s.time);
                final timeStr = AppDateFormatter.formatTime(s.time);
                final isActive = s.isActive;
                final effectiveCatColor = isActive ? catColor : catColor.withValues(alpha: 0.35);
                final effectiveTitleColor = isActive
                    ? null
                    : (isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.7) : AppColors.lightTextSecondary.withValues(alpha: 0.7));
                final effectiveSubtitle = isActive ? dateStr : '$dateStr • Nonaktif';

                return ScheduleSlidable(
                  schedule: s,
                  child: Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 0.5,
                      ),
                    ),
                    child: ListTile(
                      onTap: () => context.push('/schedule/${s.id}'),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      leading: Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: effectiveCatColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      title: Text(
                        s.title,
                        style: theme.textTheme.titleSmall?.copyWith(color: effectiveTitleColor),
                      ),
                      subtitle: Text(
                        effectiveSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isActive ? null : (isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.5) : AppColors.lightTextSecondary.withValues(alpha: 0.6)),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeStr,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                              color: isActive
                                  ? (isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator)
                                  : (isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.6) : AppColors.lightTextSecondary.withValues(alpha: 0.7)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: isActive,
                            activeThumbColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            onChanged: (val) {
                              ref.read(scheduleListProvider.notifier).toggleSchedule(s.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBulkOptionsSheet(
          context,
          category,
          catColor,
          isDark,
        ),
        icon: const Icon(Icons.add_to_photos_outlined),
        label: const Text('Tambah Banyak Jadwal'),
        backgroundColor: catColor,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showAddBulkOptionsSheet(
    BuildContext context,
    Category category,
    Color catColor,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Tambah Banyak Jadwal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Opsi 1: Manual Kalender
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calendar_month_outlined,
                      color: catColor,
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Pilih Manual di Kalender',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Untuk tanggal spesifik yang tidak berpola, misal jadwal pertandingan',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    context.push(
                      '/categories/${category.id}/calendar',
                      extra: category,
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Opsi 2: Generate Otomatis (Slot)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isDark
                              ? AppColors.amberDarkIndicator
                              : AppColors.amberLightIndicator)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: isDark
                          ? AppColors.amberDarkIndicator
                          : AppColors.amberLightIndicator,
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Generate Otomatis (Slot)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Untuk jadwal rutin jam yang sama, kontennya beda tiap hari - misal main game gantian',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    context.push(
                      '/categories/${category.id}/slot-generator',
                      extra: category,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _CategoryEditSheet(category: category),
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, WidgetRef ref, Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: const Text(
            'Jadwal dengan kategori ini tidak akan terhapus, tetapi label kategorinya akan dilepas.'),
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
    if (confirmed == true && context.mounted) {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.deleteCategory(category.id);
      if (context.mounted) context.pop();
    }
  }
}

// ── Edit Sheet ────────────────────────────────────────────────────────────────

class _CategoryEditSheet extends ConsumerStatefulWidget {
  final Category category;
  const _CategoryEditSheet({required this.category});

  @override
  ConsumerState<_CategoryEditSheet> createState() => _CategoryEditSheetState();
}

class _CategoryEditSheetState extends ConsumerState<_CategoryEditSheet> {
  final _nameController = TextEditingController();
  late String _selectedHex;
  String? _selectedRingtoneUri;
  String? _selectedRingtoneTitle;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.category.name;
    _selectedHex = widget.category.colorHex;
    _selectedRingtoneUri = widget.category.ringtoneUri;
    if (_selectedRingtoneUri != null && _selectedRingtoneUri!.isNotEmpty) {
      _loadRingtoneTitle(_selectedRingtoneUri!);
    }
  }

  Future<void> _loadRingtoneTitle(String uri) async {
    final title = await RingtoneService().getRingtoneTitle(uri);
    if (mounted) {
      setState(() => _selectedRingtoneTitle = title);
    }
  }

  Future<void> _openRingtonePicker() async {
    final result = await showRingtonePickerSheet(
      context,
      currentUri: _selectedRingtoneUri,
      currentTitle: _selectedRingtoneTitle,
      showReset: true,
    );

    if (result != null && mounted) {
      setState(() {
        if (result.isReset) {
          _selectedRingtoneUri = null;
          _selectedRingtoneTitle = null;
        } else {
          _selectedRingtoneUri = result.uri;
          _selectedRingtoneTitle = result.title;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Kategori',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                hintText: 'Contoh: Kerja, Kesehatan, Belajar...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama kategori tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CategoryColorPickerField(
              selectedHex: _selectedHex,
              onColorChanged: (hex) => setState(() => _selectedHex = hex),
            ),
            const SizedBox(height: 20),
            Text(
              'Ringtone Alarm (Opsional)',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 8),
            Material(
              color: isDark ? const Color(0xFF22242B) : const Color(0xFFF4F6F9),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: _openRingtonePicker,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        _selectedRingtoneUri != null
                            ? Icons.music_note_rounded
                            : Icons.notifications_none_rounded,
                        color: _selectedRingtoneUri != null
                            ? AppColors.accentAmber
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedRingtoneUri != null
                              ? (_selectedRingtoneTitle ?? 'Ringtone Kustom')
                              : 'Pakai Ringtone Default',
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedRingtoneUri != null
                                ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            fontWeight: _selectedRingtoneUri != null ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      foregroundColor: isDark
                          ? AppColors.darkBackground
                          : AppColors.lightBackground,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.updateCategory(
        id: widget.category.id,
        name: _nameController.text.trim(),
        colorHex: _selectedHex,
        ringtoneUri: Value(_selectedRingtoneUri),
      );
      if (mounted) Navigator.pop(context);
    }
  }
}
