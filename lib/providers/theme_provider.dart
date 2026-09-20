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

/// Provider SharedPreferences yang di-override di main() via ProviderScope.
/// Dengan ini tidak ada async gap antara startup dan pembacaan tema.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider harus di-override di ProviderScope '
    'sebelum runApp() dipanggil.',
  );
});

/// Provider untuk tema aplikasi.
/// State awal langsung dibaca dari SharedPreferences yang sudah tersedia —
/// TIDAK ada race condition karena prefs sudah di-inject synchronously.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(ref.read(sharedPreferencesProvider)),
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs)
      : super(_intToThemeMode(_prefs.getInt(_kThemeModeKey)));
  // ↑ State awal dibaca SYNCHRONOUSLY dari prefs yang sudah ter-init.
  //   Tidak ada async, tidak ada _init(), tidak ada frame pertama yang "salah tema".

  /// Simpan [mode] ke SharedPreferences lalu update state.
  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setInt(_kThemeModeKey, _themeModeToInt(mode));
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
