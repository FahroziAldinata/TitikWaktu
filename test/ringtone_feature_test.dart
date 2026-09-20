import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titik_waktu/providers/ringtone_provider.dart';
import 'package:titik_waktu/providers/theme_provider.dart';
import 'package:titik_waktu/widgets/ringtone_picker_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ringtone Feature Tests', () {
    test('DefaultRingtoneNotifier initial state is empty when SharedPreferences has no data', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final state = container.read(defaultRingtoneProvider);
      expect(state.isSet, isFalse);
      expect(state.uri, isNull);
      expect(state.title, isNull);
    });

    test('DefaultRingtoneNotifier loads existing uri and title from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        kDefaultRingtoneUriKey: 'content://media/internal/audio/media/12',
        kDefaultRingtoneTitleKey: 'Classic Alarm',
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final state = container.read(defaultRingtoneProvider);
      expect(state.isSet, isTrue);
      expect(state.uri, 'content://media/internal/audio/media/12');
      expect(state.title, 'Classic Alarm');
    });

    test('DefaultRingtoneNotifier updates and persists ringtone', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final notifier = container.read(defaultRingtoneProvider.notifier);
      await notifier.setRingtone('content://custom/alarm/42', 'My Custom Sound');

      final updatedState = container.read(defaultRingtoneProvider);
      expect(updatedState.isSet, isTrue);
      expect(updatedState.uri, 'content://custom/alarm/42');
      expect(updatedState.title, 'My Custom Sound');

      expect(prefs.getString(kDefaultRingtoneUriKey), 'content://custom/alarm/42');
      expect(prefs.getString(kDefaultRingtoneTitleKey), 'My Custom Sound');

      // Reset
      await notifier.reset();
      final resetState = container.read(defaultRingtoneProvider);
      expect(resetState.isSet, isFalse);
      expect(resetState.uri, isNull);
      expect(prefs.getString(kDefaultRingtoneUriKey), isNull);
    });

    testWidgets('RingtonePickerSheet renders options correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRingtonePickerSheet(
                  context,
                  currentUri: 'content://test/alarm',
                  currentTitle: 'Tone Test',
                  showReset: true,
                ),
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Ringtone Alarm'), findsOneWidget);
      expect(find.text('Pilih dari Nada Tersedia'), findsOneWidget);
      expect(find.text('Pilih File Sendiri'), findsOneWidget);
      expect(find.text('Ringtone Aktif'), findsOneWidget);
      expect(find.text('Tone Test'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });
  });
}
