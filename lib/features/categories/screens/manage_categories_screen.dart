import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/providers/category_provider.dart';
import 'package:titik_waktu/theme/app_colors.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
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

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final catColor = AppColors.parseCategoryColor(cat.colorHex);

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: catColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    cat.name,
                    style: theme.textTheme.titleMedium,
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  onTap: () => _showCategoryDialog(context, ref, category: cat),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context, ref),
        child: const Icon(Icons.add),
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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.category?.name ?? '';
    _selectedHex = widget.category?.colorHex ?? AppColors.categoryOptions.first.hex;
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
            Text(
              'Pilih Warna Dot',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: AppColors.categoryOptions.map((opt) {
                final isSelected = _selectedHex.toLowerCase() == opt.hex.toLowerCase();
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedHex = opt.hex;
                    });
                  },
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
        );
      } else {
        await repo.createCategory(
          name: name,
          colorHex: _selectedHex,
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
