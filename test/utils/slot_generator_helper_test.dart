import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titik_waktu/utils/slot_generator_helper.dart';

void main() {
  group('SlotGeneratorHelper.generateSlotDates', () {
    test('menghasilkan N tanggal berturut-turut jika everyDay = true', () {
      final baseDate = DateTime(2026, 10, 1, 8, 0); // 1 Okt 2026 jam 08:00
      final dates = SlotGeneratorHelper.generateSlotDates(
        slotTime: const TimeOfDay(hour: 20, minute: 0),
        everyDay: true,
        weekdays: {},
        count: 5,
        startFrom: baseDate,
      );

      expect(dates.length, 5);
      expect(dates[0], DateTime(2026, 10, 1));
      expect(dates[1], DateTime(2026, 10, 2));
      expect(dates[2], DateTime(2026, 10, 3));
      expect(dates[3], DateTime(2026, 10, 4));
      expect(dates[4], DateTime(2026, 10, 5));
    });

    test('melompat ke hari berikutnya jika slot jam hari ini sudah terlewat', () {
      final baseDate = DateTime(2026, 10, 1, 21, 30); // 1 Okt 2026 jam 21:30 (lewat dari 20:00)
      final dates = SlotGeneratorHelper.generateSlotDates(
        slotTime: const TimeOfDay(hour: 20, minute: 0),
        everyDay: true,
        weekdays: {},
        count: 3,
        startFrom: baseDate,
      );

      expect(dates.length, 3);
      expect(dates[0], DateTime(2026, 10, 2));
      expect(dates[1], DateTime(2026, 10, 3));
      expect(dates[2], DateTime(2026, 10, 4));
    });

    test('hanya menyaring hari spesifik jika everyDay = false', () {
      // 1 Okt 2026 adalah Kamis (weekday = 4)
      final baseDate = DateTime(2026, 10, 1, 10, 0);
      final dates = SlotGeneratorHelper.generateSlotDates(
        slotTime: const TimeOfDay(hour: 15, minute: 0),
        everyDay: false,
        weekdays: {1, 5}, // Senin (1) dan Jumat (5)
        count: 4,
        startFrom: baseDate,
      );

      expect(dates.length, 4);
      for (final d in dates) {
        expect(d.weekday == 1 || d.weekday == 5, isTrue);
      }
      expect(dates[0], DateTime(2026, 10, 2)); // Jumat (5)
      expect(dates[1], DateTime(2026, 10, 5)); // Senin (1)
      expect(dates[2], DateTime(2026, 10, 9)); // Jumat (5)
      expect(dates[3], DateTime(2026, 10, 12)); // Senin (1)
    });
  });

  group('SlotGeneratorHelper.assignItemsToOccurrences', () {
    final sampleDates = List.generate(
      10,
      (i) => DateTime(2026, 10, i + 1),
    );

    test('daftar item kosong menghasilkan map dengan judul string kosong', () {
      final result = SlotGeneratorHelper.assignItemsToOccurrences(
        sampleDates,
        [],
      );

      expect(result.length, 10);
      for (final date in sampleDates) {
        expect(result[date], '');
      }
    });

    test('hanya 1 item memetakan semua tanggal ke item tersebut', () {
      final result = SlotGeneratorHelper.assignItemsToOccurrences(
        sampleDates,
        ['Game Tunggal'],
      );

      expect(result.length, 10);
      for (final date in sampleDates) {
        expect(result[date], 'Game Tunggal');
      }
    });

    test('tidak ada 2 item sama berturut-turut pada perbatasan siklus (3 items, 15 dates)', () {
      final dates = List.generate(15, (i) => DateTime(2026, 10, i + 1));
      final items = ['Zelda', 'Mario', 'Pokemon'];

      // Uji berulang kali dengan seed acak berbeda
      for (var seed = 0; seed < 50; seed++) {
        final rng = Random(seed);
        final result = SlotGeneratorHelper.assignItemsToOccurrences(
          dates,
          items,
          rng,
        );

        expect(result.length, 15);
        final values = dates.map((d) => result[d]!).toList();

        // Verifikasi tidak ada dua item berturut-turut yang sama
        for (var i = 0; i < values.length - 1; i++) {
          expect(
            values[i] == values[i + 1],
            isFalse,
            reason: 'Item berurutan sama ditemukan pada index $i dan ${i + 1}: ${values[i]} (seed: $seed)',
          );
        }

        // Verifikasi dalam tiap siklus 3, item lengkap dan unik
        for (var c = 0; c < 5; c++) {
          final cycleItems = values.sublist(c * 3, c * 3 + 3);
          expect(cycleItems.toSet().length, 3);
          expect(cycleItems.toSet(), {'Zelda', 'Mario', 'Pokemon'});
        }
      }
    });

    test('distribusi merata jika jumlah item lebih sedikit dari tanggal', () {
      final dates = List.generate(30, (i) => DateTime(2026, 10, i + 1));
      final items = ['A', 'B', 'C'];
      final result = SlotGeneratorHelper.assignItemsToOccurrences(
        dates,
        items,
        Random(42),
      );

      final counts = <String, int>{'A': 0, 'B': 0, 'C': 0};
      for (final d in dates) {
        counts[result[d]!] = (counts[result[d]!] ?? 0) + 1;
      }

      // 30 / 3 = 10 masing-masing
      expect(counts['A'], 10);
      expect(counts['B'], 10);
      expect(counts['C'], 10);
    });
  });
}
