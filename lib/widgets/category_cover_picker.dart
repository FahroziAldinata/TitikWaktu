import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:titik_waktu/theme/app_colors.dart';

class CategoryCoverPicker extends StatefulWidget {
  final String? initialImageUri;
  final ValueChanged<String?> onImageChanged;

  const CategoryCoverPicker({
    super.key,
    this.initialImageUri,
    required this.onImageChanged,
  });

  @override
  State<CategoryCoverPicker> createState() => _CategoryCoverPickerState();
}

class _CategoryCoverPickerState extends State<CategoryCoverPicker> {
  String? _currentUri;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUri = widget.initialImageUri;
  }

  Future<void> _pickImage() async {
    try {
      setState(() => _isLoading = true);
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final coversDir = Directory(p.join(appDir.path, 'category_covers'));
        if (!coversDir.existsSync()) {
          coversDir.createSync(recursive: true);
        }
        final ext = p.extension(picked.path).isNotEmpty ? p.extension(picked.path) : '.jpg';
        final newPath = p.join(
          coversDir.path,
          'cover_${DateTime.now().millisecondsSinceEpoch}$ext',
        );
        final savedFile = await File(picked.path).copy(newPath);

        setState(() {
          _currentUri = savedFile.path;
        });
        widget.onImageChanged(_currentUri);
      }
    } catch (e) {
      debugPrint('Error picking category cover: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _removeImage() {
    setState(() {
      _currentUri = null;
    });
    widget.onImageChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasValidImage = _currentUri != null &&
        _currentUri!.isNotEmpty &&
        File(_currentUri!).existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Foto Sampul Kategori (Opsional)',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
            if (hasValidImage)
              TextButton(
                onPressed: _removeImage,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: Colors.redAccent,
                ),
                child: const Text('Hapus Sampul', style: TextStyle(fontSize: 11)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (hasValidImage)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(_currentUri!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Material(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: _isLoading ? null : _pickImage,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_library_outlined, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Ganti Foto', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          Material(
            color: isDark ? const Color(0xFF22242B) : const Color(0xFFF4F6F9),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: _isLoading ? null : _pickImage,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 72,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.8,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 22,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pilih Cover dari Galeri',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
      ],
    );
  }
}
