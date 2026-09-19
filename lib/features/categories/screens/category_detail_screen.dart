import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/providers/bulk_schedule_provider.dart';
import 'package:titik_waktu/providers/category_provider.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:titik_waktu/theme/app_colors.dart';
import 'package:titik_waktu/utils/date_format_helper.dart';

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
          return ListView.separated(
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

              return Card(
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
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/categories/$categoryId/calendar',
          extra: category,
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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.category.name;
    _selectedHex = widget.category.colorHex;
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
            Text(
              'Pilih Warna Dot',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: AppColors.categoryOptions.map((opt) {
                final isSelected =
                    _selectedHex.toLowerCase() == opt.hex.toLowerCase();
                return GestureDetector(
                  onTap: () => setState(() => _selectedHex = opt.hex),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: opt.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? Colors.white : Colors.black)
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
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
      );
      if (mounted) Navigator.pop(context);
    }
  }
}
