import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/providers/category_provider.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:titik_waktu/services/ringtone_service.dart';
import 'package:titik_waktu/theme/app_colors.dart';
import 'package:titik_waktu/widgets/category_color_picker_field.dart';
import 'package:titik_waktu/widgets/category_cover_picker.dart';
import 'package:titik_waktu/widgets/ringtone_picker_sheet.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final scheduleCounts = ref.watch(categoryScheduleCountProvider);
    final upcomingDatesAsync = ref.watch(categoryUpcomingDatesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum Ada Kategori',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kelompokkan jadwal Anda dengan kategori',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => _showCategoryDialog(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Kategori'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final catColor = AppColors.parseCategoryColor(cat.colorHex);
              final count = scheduleCounts[cat.id] ?? 0;
              final upcomingDates = upcomingDatesAsync.value?[cat.id] ?? [];
              final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
              final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

              final hasCover = cat.coverImageUri != null &&
                  cat.coverImageUri!.isNotEmpty &&
                  File(cat.coverImageUri!).existsSync();

              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: cardBorder, width: 0.5),
                ),
                margin: EdgeInsets.zero,
                child: InkWell(
                  onTap: () => context.push('/categories/${cat.id}'),
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
                                File(cat.coverImageUri!),
                                fit: BoxFit.cover,
                              )
                            else
                              Container(
                                color: catColor.withOpacity(0.35),
                                child: Center(
                                  child: Icon(
                                    Icons.folder_outlined,
                                    size: 32,
                                    color: catColor,
                                  ),
                                ),
                              ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      cardBg.withOpacity(0.85),
                                      cardBg,
                                    ],
                                    stops: const [0.35, 0.85, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bottom 50%: Category details
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          cat.name,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 14),
                                    child: Text(
                                      '$count jadwal',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (upcomingDates.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.06)
                                        : Colors.black.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    DateFormat('d MMM', 'id').format(upcomingDates.first),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator,
                                    ),
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
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton(
          onPressed: () => _showCategoryDialog(context, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref, {Category? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _CategoryFormSheet(category: category),
    );
  }
}

class _CategoryFormSheet extends ConsumerStatefulWidget {
  final Category? category;

  const _CategoryFormSheet({this.category});

  @override
  ConsumerState<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<_CategoryFormSheet> {
  final _nameController = TextEditingController();
  late String _selectedHex;
  String? _selectedRingtoneUri;
  String? _selectedRingtoneTitle;
  String? _selectedCoverUri;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.category?.name ?? '';
    _selectedHex = widget.category?.colorHex ?? AppColors.categoryOptions.first.hex;
    _selectedRingtoneUri = widget.category?.ringtoneUri;
    _selectedCoverUri = widget.category?.coverImageUri;
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
    final isEditing = widget.category != null;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Kategori' : 'Tambah Kategori',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                    onPressed: _deleteCategory,
                    tooltip: 'Hapus Kategori',
                  ),
              ],
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
              onColorChanged: (hex) {
                setState(() => _selectedHex = hex);
              },
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
            const SizedBox(height: 20),
            CategoryCoverPicker(
              initialImageUri: _selectedCoverUri,
              onImageChanged: (uri) {
                setState(() => _selectedCoverUri = uri);
              },
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
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saveCategory,
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      foregroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
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

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      final repo = ref.read(categoryRepositoryProvider);
      final name = _nameController.text.trim();

      if (widget.category != null) {
        await repo.updateCategory(
          id: widget.category!.id,
          name: name,
          colorHex: _selectedHex,
          ringtoneUri: Value(_selectedRingtoneUri),
          coverImageUri: Value(_selectedCoverUri),
        );
      } else {
        await repo.createCategory(
          name: name,
          colorHex: _selectedHex,
          ringtoneUri: _selectedRingtoneUri,
          coverImageUri: _selectedCoverUri,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _deleteCategory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: const Text('Jadwal dengan kategori ini tidak akan terhapus, tetapi label kategorinya akan dilepas.'),
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

    if (confirmed == true && widget.category != null) {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.deleteCategory(widget.category!.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
