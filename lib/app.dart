import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/providers/permission_provider.dart';
import 'package:titik_waktu/utils/theme.dart';
import 'package:titik_waktu/utils/router.dart';

class TitikWaktuApp extends ConsumerStatefulWidget {
  const TitikWaktuApp({super.key});

  @override
  ConsumerState<TitikWaktuApp> createState() => _TitikWaktuAppState();
}

class _TitikWaktuAppState extends ConsumerState<TitikWaktuApp> {
  bool _initialRouteChecked = false;

  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(permissionProvider);

    if (!permissionState.isLoading && !_initialRouteChecked) {
      _initialRouteChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!permissionState.onboardingComplete) {
          context.go('/permissions/onboarding');
        }
      });
    }

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
