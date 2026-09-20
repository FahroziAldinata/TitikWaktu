import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider untuk tema aplikasi.
/// Menyimpan [ThemeMode] (system / light / dark) dan memungkinkan toggle.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  /// Cycle: system → light → dark → system
  void toggle() {
    state = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }

  /// Set langsung ke mode tertentu
  void setMode(ThemeMode mode) {
    state = mode;
  }
}
