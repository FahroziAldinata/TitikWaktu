import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'app_theme_mode';

/// Mapping antara nilai int (di SharedPreferences) dan [ThemeMode].
int _themeModeToInt(ThemeMode mode) => switch (mode) {
      ThemeMode.system => 0,
      ThemeMode.light => 1,
      ThemeMode.dark => 2,
    };

ThemeMode _intToThemeMode(int? value) => switch (value) {
      1 => ThemeMode.light,
      2 => ThemeMode.dark,
      _ => ThemeMode.system, // default / null / unknown → system
    };

/// Provider untuk tema aplikasi.
/// State awal: [ThemeMode.system].
/// Setelah [_init()] selesai, state diperbarui dari SharedPreferences.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _init();
  }

  /// Baca nilai yang tersimpan dari SharedPreferences saat startup.
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_kThemeModeKey);
    // Hanya update jika mounted (widget masih hidup)
    if (mounted) {
      state = _intToThemeMode(saved);
    }
  }

  /// Simpan [mode] ke SharedPreferences lalu update state.
  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeModeKey, _themeModeToInt(mode));
  }

  /// Cycle: system → light → dark → system, dengan persistensi.
  Future<void> toggle() async {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setMode(next);
  }
}
