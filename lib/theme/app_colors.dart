import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Light Mode ---
  static const lightBackground = Color(0xFFFAFAF9);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE5E4E1);
  static const lightTextPrimary = Color(0xFF1C1C1A);
  static const lightTextSecondary = Color(0xFF8A8985);

  // --- Dark Mode ---
  static const darkBackground = Color(0xFF151412);
  static const darkSurface = Color(0xFF1C1B18);
  static const darkBorder = Color(0xFF33322D);
  static const darkTextPrimary = Color(0xFFF0EFEA);
  static const darkTextSecondary = Color(0xFF8A8985);

  // --- Amber Accent (Khusus Alarm / Waktu) ---
  // Light Mode Amber
  static const amberLightIndicator = Color(0xFFBA7517);
  static const amberLightHighlightBg = Color(0xFFFCF6EC);
  static const amberLightHighlightBorder = Color(0xFFF3E1BE);
  static const amberLightHighlightTitle = Color(0xFF633806);
  static const amberLightHighlightSubtitle = Color(0xFF854F0B);

  // Dark Mode Amber
  static const amberDarkIndicator = Color(0xFFFAC775);
  static const amberDarkHighlightBg = Color(0xFF241C0D);
  static const amberDarkHighlightBorder = Color(0xFF4A3714);
  static const amberDarkHighlightTitle = Color(0xFFFAC775);
  static const amberDarkHighlightSubtitle = Color(0xFFEF9F27);

  // --- 6 Palet Warna Kategori Solid ---
  static const categoryGreen = Color(0xFF639922);
  static const categoryBlue = Color(0xFF378ADD);
  static const categoryCoral = Color(0xFFD85A30);
  static const categoryPink = Color(0xFFD4537E);
  static const categoryTeal = Color(0xFF1D9E75);
  static const categoryAmber = Color(0xFFBA7517);

  static const List<CategoryColorOption> categoryOptions = [
    CategoryColorOption(name: 'Hijau', hex: '#639922', color: categoryGreen),
    CategoryColorOption(name: 'Biru', hex: '#378ADD', color: categoryBlue),
    CategoryColorOption(name: 'Coral', hex: '#D85A30', color: categoryCoral),
    CategoryColorOption(name: 'Pink', hex: '#D4537E', color: categoryPink),
    CategoryColorOption(name: 'Teal', hex: '#1D9E75', color: categoryTeal),
    CategoryColorOption(name: 'Amber', hex: '#BA7517', color: categoryAmber),
  ];

  static Color parseCategoryColor(String? hexString, {Color fallback = categoryAmber}) {
    if (hexString == null || hexString.isEmpty) return fallback;
    try {
      var hex = hexString.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}

class CategoryColorOption {
  final String name;
  final String hex;
  final Color color;

  const CategoryColorOption({
    required this.name,
    required this.hex,
    required this.color,
  });
}
