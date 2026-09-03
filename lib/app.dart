import 'package:flutter/material.dart';
import 'package:titik_waktu/utils/theme.dart';
import 'package:titik_waktu/utils/router.dart';

class TitikWaktuApp extends StatelessWidget {
  const TitikWaktuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Titik Waktu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
