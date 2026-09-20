import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:titik_waktu/providers/theme_provider.dart';
import 'package:titik_waktu/repositories/schedule_repository.dart';
import 'package:titik_waktu/widgets/schedule_slidable.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockScheduleRepository mockRepo;
  late SharedPreferences prefs;

  final testSchedule = Schedule(
    id: 101,
    title: 'Test Workout',
    description: 'Gym session',
    time: DateTime(2026, 9, 20, 7, 0),
    startDate: DateTime(2026, 9, 20),
    isActive: true,
    notificationType: 1,
    recurrenceType: 1,
    recurrenceRule: null,
    exceptionDates: null,
    categoryId: null,
    color: null,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() async {
    mockRepo = MockScheduleRepository();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    when(() => mockRepo.getAllSchedules()).thenAnswer((_) async => [testSchedule]);
    when(() => mockRepo.deleteSchedule(any())).thenAnswer((_) async => true);
  });

  Widget buildTestWidget({
    required Schedule schedule,
    VoidCallback? onEdit,
    VoidCallback? onDeleted,
    Future<void> Function(Schedule)? onDelete,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        scheduleRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 380,
              height: 100,
              child: ScheduleSlidable(
                schedule: schedule,
                onEdit: onEdit,
                onDeleted: onDeleted,
                onDelete: onDelete,
                child: Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(child: Text(schedule.title)),
                      Switch(
                        value: schedule.isActive,
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('ScheduleSlidable Tests', () {
    testWidgets('Swipe LEFT reveals Edit action with pencil icon', (tester) async {
      bool editCalled = false;

      await tester.pumpWidget(buildTestWidget(
        schedule: testSchedule,
        onEdit: () => editCalled = true,
      ));
      await tester.pumpAndSettle();

      // Swipe from right to left across the widget
      await tester.drag(find.byType(ScheduleSlidable), const Offset(-200, 0));
      await tester.pumpAndSettle();

      // Edit action should be visible
      expect(find.text('Edit'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

      // Tap Edit
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(editCalled, isTrue);
    });

    testWidgets('Swipe RIGHT reveals Hapus action with statusError color and trash icon', (tester) async {
      await tester.pumpWidget(buildTestWidget(schedule: testSchedule));
      await tester.pumpAndSettle();

      // Swipe from left to right across the widget
      await tester.drag(find.byType(ScheduleSlidable), const Offset(200, 0));
      await tester.pumpAndSettle();

      // Hapus action should be visible
      expect(find.text('Hapus'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);

      // Tap Hapus -> Confirmation dialog should appear
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Jadwal?'), findsOneWidget);
      expect(find.text('Jadwal akan dihapus secara permanen.'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
    });

    testWidgets('Confirming delete in dialog triggers deleteSchedule', (tester) async {
      bool deletedCalled = false;
      bool deleteHandlerCalled = false;

      await tester.pumpWidget(buildTestWidget(
        schedule: testSchedule,
        onDelete: (s) async {
          deleteHandlerCalled = true;
          await mockRepo.deleteSchedule(s.id);
        },
        onDeleted: () => deletedCalled = true,
      ));
      await tester.pumpAndSettle();

      // Swipe right and tap Hapus
      await tester.drag(find.byType(ScheduleSlidable), const Offset(200, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Tap Hapus button inside dialog
      final dialogHapusBtn = find.widgetWithText(TextButton, 'Hapus');
      await tester.tap(dialogHapusBtn);
      await tester.pumpAndSettle();

      verify(() => mockRepo.deleteSchedule(101)).called(1);
      expect(deleteHandlerCalled, isTrue);
      expect(deletedCalled, isTrue);
    });

    testWidgets('Canceling delete dialog does NOT delete schedule', (tester) async {
      bool deletedCalled = false;

      await tester.pumpWidget(buildTestWidget(
        schedule: testSchedule,
        onDelete: (s) async => mockRepo.deleteSchedule(s.id),
        onDeleted: () => deletedCalled = true,
      ));
      await tester.pumpAndSettle();

      // Swipe right and tap Hapus
      await tester.drag(find.byType(ScheduleSlidable), const Offset(200, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Tap Batal button inside dialog
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      verifyNever(() => mockRepo.deleteSchedule(any()));
      expect(deletedCalled, isFalse);
    });

    testWidgets('Works properly on inactive (dimmed) schedule', (tester) async {
      final inactiveSchedule = testSchedule.copyWith(isActive: false);

      await tester.pumpWidget(buildTestWidget(schedule: inactiveSchedule));
      await tester.pumpAndSettle();

      // Swipe left for edit on inactive
      await tester.drag(find.byType(ScheduleSlidable), const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);

      // Close slidable
      await tester.drag(find.byType(ScheduleSlidable), const Offset(200, 0));
      await tester.pumpAndSettle();

      // Swipe right for delete on inactive
      await tester.drag(find.byType(ScheduleSlidable), const Offset(200, 0));
      await tester.pumpAndSettle();
      expect(find.text('Hapus'), findsOneWidget);
    });
  });
}
