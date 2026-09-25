import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titik_waktu/providers/bulk_schedule_provider.dart';

void main() {
  test('bulkScheduleProvider autoDispose without active listener resets state', () async {
    final container = ProviderContainer();
    final testDate = DateTime(2026, 10, 1);
    
    // Simulate old SlotGeneratorScreen calling initFromSlotGenerator via ref.read without watching
    container.read(bulkScheduleProvider.notifier).initFromSlotGenerator(
      dates: [testDate],
      slotTime: const TimeOfDay(hour: 20, minute: 0),
      titles: {testDate: 'Item 1'},
    );

    // After microtask without listener, autoDispose wipes it
    await Future.delayed(Duration.zero);
    final stateAfter = container.read(bulkScheduleProvider);
    expect(stateAfter.selectedDates.length, 0);
  });

  test('bulkScheduleProvider with active watcher maintains state across navigation', () async {
    final container = ProviderContainer();
    final testDate = DateTime(2026, 10, 1);
    
    // Simulate SlotGeneratorScreen watching the provider in build()
    final subscription = container.listen<BulkScheduleState>(
      bulkScheduleProvider,
      (previous, next) {},
    );

    // Call initFromSlotGenerator
    container.read(bulkScheduleProvider.notifier).initFromSlotGenerator(
      dates: [testDate],
      slotTime: const TimeOfDay(hour: 20, minute: 0),
      titles: {testDate: 'Tugas Alpha'},
    );

    // Microtask passes (simulating route push)
    await Future.delayed(Duration.zero);

    // BulkTimeSetterScreen mounts and reads
    final stateOnReviewScreen = container.read(bulkScheduleProvider);
    expect(stateOnReviewScreen.selectedDates.length, 1);
    expect(stateOnReviewScreen.timeMap[testDate], const TimeOfDay(hour: 20, minute: 0));
    expect(stateOnReviewScreen.titleMap[testDate], 'Tugas Alpha');

    // Close screen / subscription
    subscription.close();
  });

  test('skenario state bersih: reset() membersihkan seluruh state tanpa sisa', () async {
    final container = ProviderContainer();
    final testDateA = DateTime(2026, 10, 1);
    final testDateB = DateTime(2026, 10, 2);

    final sub = container.listen(bulkScheduleProvider, (_, __) {});

    // Sesi 1: Kategori A
    container.read(bulkScheduleProvider.notifier).initFromSlotGenerator(
      dates: [testDateA, testDateB],
      slotTime: const TimeOfDay(hour: 19, minute: 30),
      titles: {testDateA: 'Film A', testDateB: 'Film B'},
    );

    expect(container.read(bulkScheduleProvider).selectedDates.length, 2);
    expect(container.read(bulkScheduleProvider).timeMap.length, 2);
    expect(container.read(bulkScheduleProvider).titleMap.length, 2);

    // Selesai / simpan / reset
    container.read(bulkScheduleProvider.notifier).reset();

    // Sesi 2: Kategori B (harus benar-benar bersih dari sesi A)
    final cleanState = container.read(bulkScheduleProvider);
    expect(cleanState.selectedDates.isEmpty, isTrue);
    expect(cleanState.timeMap.isEmpty, isTrue);
    expect(cleanState.titleMap.isEmpty, isTrue);

    sub.close();
  });
}
