import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:titik_waktu/theme/app_colors.dart';

class CategoryColorPickerField extends StatelessWidget {
  final String selectedHex;
  final ValueChanged<String> onColorChanged;

  const CategoryColorPickerField({
    super.key,
    required this.selectedHex,
    required this.onColorChanged,
  });

  String _toHex(Color color) {
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  void _openCustomColorPicker(BuildContext context) {
    Color pickerColor = AppColors.parseCategoryColor(selectedHex);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final luminance = pickerColor.computeLuminance();
            final isLowContrastLight = luminance > 0.82;
            final isLowContrastDark = luminance < 0.12;

            return AlertDialog(
              title: const Text('Pilih Warna Bebas'),
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ColorPicker(
                      pickerColor: pickerColor,
                      onColorChanged: (color) {
                        setDialogState(() {
                          pickerColor = color;
                        });
                      },
                      colorPickerWidth: 260,
                      pickerAreaHeightPercent: 0.6,
                      enableAlpha: false,
                      displayThumbColor: true,
                      paletteType: PaletteType.hsvWithHue,
                      labelTypes: const [ColorLabelType.hex, ColorLabelType.rgb],
                      hexInputBar: true,
                    ),
                    const SizedBox(height: 12),
                    // ── Live Preview Kontras (Terang & Gelap Berdampingan) ──
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Preview Kontras Tampilan:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildContrastCardPreview(
                            title: 'Mode Terang',
                            bgColor: const Color(0xFFFFFFFF),
                            textColor: const Color(0xFF1F2937),
                            borderColor: const Color(0xFFE5E7EB),
                            accentColor: pickerColor,
                            isWarning: isLowContrastLight,
                            warningText: 'Kontras rendah di mode terang',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildContrastCardPreview(
                            title: 'Mode Gelap',
                            bgColor: const Color(0xFF1A1D24),
                            textColor: const Color(0xFFF9FAFB),
                            borderColor: const Color(0xFF2E333D),
                            accentColor: pickerColor,
                            isWarning: isLowContrastDark,
                            warningText: 'Kontras rendah di mode gelap',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () {
                    onColorChanged(_toHex(pickerColor));
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Pilih Warna'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildContrastCardPreview({
    required String title,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
    required Color accentColor,
    required bool isWarning,
    required String warningText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Contoh Jadwal',
            style: TextStyle(
              fontSize: 10,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          if (isWarning) ...[
            const SizedBox(height: 4),
            Text(
              '⚠️ $warningText',
              style: const TextStyle(
                fontSize: 9,
                color: Colors.amber,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentColor = AppColors.parseCategoryColor(selectedHex);

    // Cek apakah warna saat ini termasuk salah satu dari preset lama
    final isPresetSelected = AppColors.categoryOptions.any(
      (opt) => opt.hex.toLowerCase() == selectedHex.toLowerCase(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pilih Warna Kategori',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
            // Tampilan Hex Code aktif
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: currentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: currentColor.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                selectedHex.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: currentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Preset Row + Tombol Custom Picker
        Row(
          children: [
            ...AppColors.categoryOptions.map((opt) {
              final isSelected =
                  selectedHex.toLowerCase() == opt.hex.toLowerCase();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onColorChanged(opt.hex),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: opt.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? Colors.white : Colors.black)
                            : Colors.transparent,
                        width: 2.2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
              );
            }),
            // Tombol Picker Custom
            InkWell(
              onTap: () => _openCustomColorPicker(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: !isPresetSelected
                      ? currentColor.withValues(alpha: 0.2)
                      : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: !isPresetSelected
                        ? currentColor
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: !isPresetSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      size: 16,
                      color: !isPresetSelected
                          ? currentColor
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      !isPresetSelected ? 'Kustom' : 'Lainnya',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: !isPresetSelected
                            ? currentColor
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
