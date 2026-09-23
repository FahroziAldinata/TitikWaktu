import 'dart:math';
import 'package:flutter/material.dart';

class SlotGeneratorHelper {
  SlotGeneratorHelper._();

  /// Menghitung N tanggal ke depan sesuai pola slot waktu dan hari.
  ///
  /// - [slotTime]: Jam tetap untuk setiap slot.
  /// - [everyDay]: Jika true, jadwal akan dibuat setiap hari berturut-turut.
  /// - [weekdays]: Set angka hari (1 = Senin, ..., 7 = Minggu) jika [everyDay] false.
  /// - [count]: Jumlah occurrence yang ingin di-generate (misal 30).
  /// - [startFrom]: Tanggal/waktu acuan (default ke DateTime.now()). Jika waktu slot hari ini
  ///   sudah lewat, secara otomatis dimulai dari esok hari.
  static List<DateTime> generateSlotDates({
    required TimeOfDay slotTime,
    required bool everyDay,
    required Set<int> weekdays,
    required int count,
    DateTime? startFrom,
  }) {
    if (count <= 0) return [];

    final now = startFrom ?? DateTime.now();
    DateTime current = DateTime(now.year, now.month, now.day);

    // Jika waktu acuan adalah hari ini dan slot jam hari ini sudah terlewat,
    // mulai perhitungan dari besok agar tidak menjadwalkan di masa lalu.
    final todaySlot = DateTime(
      now.year,
      now.month,
      now.day,
      slotTime.hour,
      slotTime.minute,
    );
    if (todaySlot.isBefore(now)) {
      current = current.add(const Duration(days: 1));
    }

    final dates = <DateTime>[];
    // Safety guard max 5 tahun untuk menghindari infinite loop jika weekdays kosong
    final maxIterations = count * 365 + 1000;
    var iterations = 0;

    while (dates.length < count && iterations < maxIterations) {
      iterations++;
      final candidate = DateTime(current.year, current.month, current.day);
      final matches = everyDay || weekdays.contains(candidate.weekday);

      if (matches) {
        dates.add(candidate);
      }
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  /// Membagikan item dari [items] ke [dates] secara acak dengan pola shuffle-per-siklus:
  ///
  /// - List item diacak per siklus (ukuran siklus = items.length).
  /// - Dipakai berurutan sampai habis, lalu diacak ulang untuk siklus berikutnya.
  /// - Dijamin tidak ada item yang keluar 2x berturut-turut di perbatasan antarsiklus
  ///   (selama items.length > 1).
  /// - Jika [items] kosong, seluruh tanggal akan dipetakan ke String kosong ("").
  /// - Jika [items] hanya ada 1, seluruh tanggal akan dipetakan ke item tersebut.
  static Map<DateTime, String> assignItemsToOccurrences(
    List<DateTime> dates,
    List<String> items, [
    Random? random,
  ]) {
    final rng = random ?? Random();
    final sortedDates = List<DateTime>.from(dates)..sort();
    final result = <DateTime, String>{};

    if (sortedDates.isEmpty) return result;

    final cleanItems = items
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (cleanItems.isEmpty) {
      for (final date in sortedDates) {
        result[date] = '';
      }
      return result;
    }

    if (cleanItems.length == 1) {
      final singleItem = cleanItems.first;
      for (final date in sortedDates) {
        result[date] = singleItem;
      }
      return result;
    }

    final assignedPool = <String>[];
    String? lastItemOfPreviousCycle;

    while (assignedPool.length < sortedDates.length) {
      final cycle = List<String>.from(cleanItems)..shuffle(rng);

      // Pastikan item pertama di siklus baru TIDAK sama dengan item terakhir siklus sebelumnya
      if (lastItemOfPreviousCycle != null && cycle.first == lastItemOfPreviousCycle) {
        // Swap dengan elemen lain secara acak (antara index 1 sampai length - 1)
        final swapIndex = rng.nextInt(cycle.length - 1) + 1;
        final temp = cycle[0];
        cycle[0] = cycle[swapIndex];
        cycle[swapIndex] = temp;
      }

      assignedPool.addAll(cycle);
      lastItemOfPreviousCycle = cycle.last;
    }

    for (var i = 0; i < sortedDates.length; i++) {
      result[sortedDates[i]] = assignedPool[i];
    }

    return result;
  }
}
