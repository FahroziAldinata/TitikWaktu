import 'package:drift/drift.dart';
import 'migration.dart';

class MigrationV3 extends Migration {
  MigrationV3() : super(3);

  @override
  Future<void> up(Migrator m, GeneratedDatabase db) async {
    print('Executing MigrationV3 UP: Converting legacy recurrence fields to RFC 5545 RRULE string...');

    final rows = await db.customSelect('SELECT id, recurrence_type, interval, days_of_week, day_of_month, start_date, recurrence_rule FROM schedules').get();

    for (final row in rows) {
      final id = row.read<int>('id');
      final recurrenceType = row.readNullable<int>('recurrence_type') ?? 0;
      final interval = row.readNullable<int>('interval') ?? 1;
      final daysOfWeek = row.readNullable<int>('days_of_week');
      final dayOfMonth = row.readNullable<int>('day_of_month');
      final existingRrule = row.readNullable<String>('recurrence_rule');

      if (existingRrule != null && existingRrule.isNotEmpty) {
        continue;
      }

      String? rrule;
      // 0: none, 1: once, 2: daily, 3: weekly, 4: monthly, 5: yearly, 6: customInterval
      switch (recurrenceType) {
        case 2: // daily
          rrule = 'RRULE:FREQ=DAILY;INTERVAL=$interval';
          break;
        case 3: // weekly
          final days = <String>[];
          if (daysOfWeek != null && daysOfWeek > 0) {
            if ((daysOfWeek & (1 << 0)) != 0) days.add('MO');
            if ((daysOfWeek & (1 << 1)) != 0) days.add('TU');
            if ((daysOfWeek & (1 << 2)) != 0) days.add('WE');
            if ((daysOfWeek & (1 << 3)) != 0) days.add('TH');
            if ((daysOfWeek & (1 << 4)) != 0) days.add('FR');
            if ((daysOfWeek & (1 << 5)) != 0) days.add('SA');
            if ((daysOfWeek & (1 << 6)) != 0) days.add('SU');
          }
          if (days.isEmpty) {
            // Default to all days if not specified
            days.addAll(['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU']);
          }
          rrule = 'RRULE:FREQ=WEEKLY;INTERVAL=$interval;BYDAY=${days.join(',')}';
          break;
        case 4: // monthly
          int targetDay = dayOfMonth ?? 1;
          if (dayOfMonth == null) {
            final startDateRaw = row.readNullable<int>('start_date');
            if (startDateRaw != null) {
              final dt = DateTime.fromMillisecondsSinceEpoch(startDateRaw * 1000);
              targetDay = dt.day;
            }
          }
          rrule = 'RRULE:FREQ=MONTHLY;INTERVAL=$interval;BYMONTHDAY=$targetDay';
          break;
        case 6: // customInterval
          rrule = 'RRULE:FREQ=DAILY;INTERVAL=$interval';
          break;
        case 0:
        case 1:
        default:
          rrule = null;
          break;
      }

      if (rrule != null) {
        await db.customUpdate(
          'UPDATE schedules SET recurrence_rule = ? WHERE id = ?',
          variables: [Variable.withString(rrule), Variable.withInt(id)],
          updates: {},
        );
        print('Migrated schedule #$id (type=$recurrenceType) -> $rrule');
      }
    }
    print('MigrationV3 UP completed.');
  }

  @override
  Future<void> down(Migrator m, GeneratedDatabase db) async {
    print('MigrationV3 DOWN: Clearing recurrence_rule...');
    await db.customUpdate('UPDATE schedules SET recurrence_rule = NULL');
    print('MigrationV3 DOWN completed.');
  }
}
