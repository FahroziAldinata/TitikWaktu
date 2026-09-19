import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:titik_waktu/features/onboarding/screens/permission_onboarding_screen.dart';
import 'package:titik_waktu/features/onboarding/widgets/permission_card.dart';
import 'package:titik_waktu/providers/permission_provider.dart';
import 'package:titik_waktu/services/permission_service.dart';
import 'package:titik_waktu/utils/theme.dart';

class MockPermissionService extends Mock implements PermissionService {}

void main() {
  late MockPermissionService mockPermissionService;

  setUp(() {
    mockPermissionService = MockPermissionService();
    when(() => mockPermissionService.isNotificationPermissionGranted())
        .thenAnswer((_) async => false);
    when(() => mockPermissionService.canScheduleExactAlarms())
        .thenAnswer((_) async => false);
    when(() => mockPermissionService.isIgnoringBatteryOptimizations())
        .thenAnswer((_) async => false);
  });

  group('Permission Onboarding & Card Tests', () {
    testWidgets('PermissionCard renders title, badge, and icon without overflow on narrow width', (tester) async {
      // Test narrow screen width (320px)
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: PermissionCard(
                title: 'Nonaktifkan Optimasi Baterai',
                description: 'Alarm tetap berbunyi meskipun aplikasi di latar belakang.',
                icon: Icons.battery_saver_rounded,
                isGranted: false,
                isOptional: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Nonaktifkan Optimasi Baterai'), findsOneWidget);
      expect(find.text('Opsional'), findsOneWidget);
      expect(find.byIcon(Icons.battery_saver_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PermissionOnboardingScreen renders all 3 permission cards and icons in Light Mode', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            permissionServiceProvider.overrideWithValue(mockPermissionService),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            home: const PermissionOnboardingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Izin yang Diperlukan'), findsOneWidget);
      expect(find.text('Notifikasi'), findsOneWidget);
      expect(find.text('Alarm Tepat Waktu'), findsOneWidget);
      expect(find.text('Nonaktifkan Optimasi Baterai'), findsOneWidget);

      // Verify all static rounded icons are rendered
      expect(find.byIcon(Icons.alarm_rounded), findsNWidgets(2)); // Header + Alarm Card
      expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
      expect(find.byIcon(Icons.battery_saver_rounded), findsOneWidget);

      // Verify no RenderFlex overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('PermissionOnboardingScreen renders properly in Dark Mode without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            permissionServiceProvider.overrideWithValue(mockPermissionService),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const PermissionOnboardingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Izin yang Diperlukan'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
      expect(find.byIcon(Icons.alarm_rounded), findsNWidgets(2));
      expect(find.byIcon(Icons.battery_saver_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
