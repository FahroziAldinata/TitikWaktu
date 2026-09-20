import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titik_waktu/app.dart';
import 'package:titik_waktu/providers/theme_provider.dart';
import 'package:titik_waktu/services/alarm_service.dart';
import 'package:titik_waktu/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Semua await diselesaikan SEBELUM runApp() — tidak ada race condition.
  await initializeDateFormatting('id_ID', null);
  await NotificationService().initialize();
  await AlarmService().initialize();

  // SharedPreferences di-init di sini, bukan di dalam ThemeNotifier.
  // Dengan ini, ThemeMode yang tersimpan sudah tersedia synchronously
  // saat ProviderScope membuat ThemeNotifier di frame pertama.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Inject prefs ke semua provider yang membutuhkannya.
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TitikWaktuApp(),
    ),
  );
}
