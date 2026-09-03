import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:titik_waktu/app.dart';
import 'package:titik_waktu/services/alarm_service.dart';
import 'package:titik_waktu/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationService().initialize();
  await AlarmService().initialize();
  
  runApp(
    const ProviderScope(
      child: TitikWaktuApp(),
    ),
  );
}
