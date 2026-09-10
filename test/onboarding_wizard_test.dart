import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titik_waktu/features/onboarding/screens/miui_onboarding_wizard_screen.dart';

void main() {
  group('MIUI Onboarding Wizard Tests', () {
    testWidgets('Wizard renders step 1 and navigates across 5 steps', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MiuiOnboardingWizardScreen(),
          ),
        ),
      );

      // Verify Step 1 Autostart
      expect(find.text('Langkah 1 dari 5'), findsOneWidget);
      expect(find.text('Mulai Otomatis (Autostart)'), findsOneWidget);
      expect(find.text('Buka Pengaturan Autostart'), findsOneWidget);

      // Tap Next -> Step 2
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('Langkah 2 dari 5'), findsOneWidget);
      expect(find.text('Penghemat Baterai (Battery Saver)'), findsOneWidget);
      expect(find.text('Buka Pengaturan Penghemat Baterai'), findsOneWidget);

      // Tap Next -> Step 3
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('Langkah 3 dari 5'), findsOneWidget);
      expect(find.text('Izin Notifikasi & Layar Kunci'), findsOneWidget);

      // Tap Next -> Step 4
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('Langkah 4 dari 5'), findsOneWidget);
      expect(find.text('Izin Jendela Pop-Up Latar Belakang'), findsOneWidget);

      // Tap Next -> Step 5
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('Langkah 5 dari 5'), findsOneWidget);
      expect(find.text('Kunci di Recent Apps (Gembok)'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
    });
  });
}
