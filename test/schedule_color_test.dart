import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/database/schedules_dao.dart';
import 'package:titik_waktu/theme/app_colors.dart';

void main() {
  late AppDatabase db;
  late SchedulesDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = SchedulesDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Schedule Color Tests', () {
    test('Schedule can be created and updated with custom color', () async {
      final customColorVal = AppColors.categoryTeal.toARGB32();

      final scheduleId = await dao.insertSchedule(
        SchedulesCompanion.insert(
          title: 'Minum Vitamin',
          time: DateTime(2026, 9, 10, 8, 30),
          color: Value(customColorVal),
        ),
      );

      final fetched = await dao.getScheduleById(scheduleId);
      expect(fetched, isNotNull);
      expect(fetched!.color, equals(customColorVal));

      // Update color to Coral
      final coralVal = AppColors.categoryCoral.toARGB32();
      await dao.updateSchedule(
        fetched.copyWith(color: Value(coralVal)),
      );

      final updated = await dao.getScheduleById(scheduleId);
      expect(updated!.color, equals(coralVal));
    });

    test('Color parsing and hex conversions work reliably', () {
      final parsed = AppColors.parseCategoryColor('#1D9E75');
      expect(parsed, equals(AppColors.categoryTeal));

      final fallback = AppColors.parseCategoryColor('invalid');
      expect(fallback, equals(AppColors.categoryAmber));
    });
  });
}
