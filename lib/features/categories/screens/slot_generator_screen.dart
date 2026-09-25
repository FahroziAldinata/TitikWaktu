import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/providers/bulk_schedule_provider.dart';
import 'package:titik_waktu/theme/app_colors.dart';
import 'package:titik_waktu/utils/recurrence_helper.dart';
import 'package:titik_waktu/utils/slot_generator_helper.dart';

class SlotGeneratorScreen extends ConsumerStatefulWidget {
  final Category category;

  const SlotGeneratorScreen({super.key, required this.category});

  @override
  ConsumerState<SlotGeneratorScreen> createState() => _SlotGeneratorScreenState();
}

class _SlotGeneratorScreenState extends ConsumerState<SlotGeneratorScreen> {
  TimeOfDay _slotTime = const TimeOfDay(hour: 20, minute: 0);
  bool _everyDay = true;
  final Set<int> _selectedWeekdays = {1, 2, 3, 4, 5, 6, 7}; // 1 = Sen .. 7 = Min
  int _occurrenceCount = 30;
  final TextEditingController _countController = TextEditingController(text: '30');

  final TextEditingController _itemInputController = TextEditingController();
  final FocusNode _itemFocusNode = FocusNode();
  final List<String> _items = [];

  NotificationType _notificationType = NotificationType.notification;

  @override
  void initState() {
    super.initState();
    // Pastikan state bulk schedule bersih saat masuk ke Slot Generator
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(bulkScheduleProvider.notifier).reset();
      }
    });
  }

  @override
  void dispose() {
    _countController.dispose();
    _itemInputController.dispose();
    _itemFocusNode.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _itemInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _items.add(text);
        _itemInputController.clear();
      });
      _itemFocusNode.requestFocus();
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _slotTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _slotTime = picked);
    }
  }

  void _generate() {
    if (!_everyDay && _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu hari dalam seminggu!'),
          backgroundColor: AppColors.statusError,
        ),
      );
      return;
    }

    final parsedCount = int.tryParse(_countController.text) ?? _occurrenceCount;
    if (parsedCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah occurrence minimal 1!'),
          backgroundColor: AppColors.statusError,
        ),
      );
      return;
    }

    final dates = SlotGeneratorHelper.generateSlotDates(
      slotTime: _slotTime,
      everyDay: _everyDay,
      weekdays: _selectedWeekdays,
      count: parsedCount,
    );

    if (dates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghasilkan tanggal sesuai pola.'),
          backgroundColor: AppColors.statusError,
        ),
      );
      return;
    }

    final assignedTitles = SlotGeneratorHelper.assignItemsToOccurrences(
      dates,
      _items,
    );

    ref.read(bulkScheduleProvider.notifier).initFromSlotGenerator(
          dates: dates,
          slotTime: _slotTime,
          titles: assignedTitles,
          notificationType: _notificationType,
        );

    // Navigasi ke BulkTimeSetterScreen
    context.push(
      '/categories/${widget.category.id}/bulk-time',
      extra: widget.category,
    );
  }

  @override
  Widget build(BuildContext context) {
    // PENTING: ref.watch di sini BUKAN untuk rebuild UI, melainkan menjaga
    // lifecycle autoDispose bulkScheduleProvider tetap aktif (listener count >= 1)
    // agar state tidak di-dispose prematur saat navigasi push ke BulkTimeSetterScreen.
    ref.watch(bulkScheduleProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catColor = AppColors.parseCategoryColor(widget.category.colorHex);

    final timeStr =
        '${_slotTime.hour.toString().padLeft(2, '0')}:${_slotTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Slot Generator — ${widget.category.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Overview Banner ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: catColor.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: isDark
                        ? AppColors.amberDarkIndicator
                        : AppColors.amberLightIndicator,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Konsep Slot Generator',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Buat jadwal berulang di jam yang sama, dengan konten yang bisa digilir tiap kemunculan (misal game, film, atau tugas kerja bergantian).',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Section 1: Pola Waktu & Hari ────────────────────────────
            _buildSectionHeader(
              context,
              icon: Icons.looks_one_rounded,
              title: 'Langkah 1: Jam & Hari (Slot Tetap)',
              color: catColor,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Slot Time Picker Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jam Slot Tetap',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Diterapkan ke semua tanggal hasil generate',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: catColor.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 18,
                                color: isDark
                                    ? AppColors.amberDarkIndicator
                                    : AppColors.amberLightIndicator,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                timeStr,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                  color: isDark
                                      ? AppColors.amberDarkIndicator
                                      : AppColors.amberLightIndicator,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Pola Hari: Setiap hari vs Hari tertentu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Setiap Hari',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: _everyDay,
                        activeThumbColor: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        activeTrackColor: catColor,
                        onChanged: (val) {
                          setState(() {
                            _everyDay = val;
                            if (_everyDay) {
                              _selectedWeekdays.addAll({1, 2, 3, 4, 5, 6, 7});
                            }
                          });
                        },
                      ),
                    ],
                  ),

                  // Selector Hari jika tidak setiap hari
                  if (!_everyDay) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Pilih hari aktif:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final weekday = index + 1; // 1 = Sen .. 7 = Min
                        final isSelected = _selectedWeekdays.contains(weekday);
                        final dayLabel = RecurrenceHelper.dayShortNames[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                if (_selectedWeekdays.length > 1) {
                                  _selectedWeekdays.remove(weekday);
                                }
                              } else {
                                _selectedWeekdays.add(weekday);
                              }
                            });
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.amberDarkIndicator
                                      : AppColors.amberLightIndicator)
                                  : (isDark
                                      ? AppColors.darkBackground
                                      : AppColors.lightBackground),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? (isDark
                                        ? AppColors.amberDarkHighlightBorder
                                        : AppColors.amberLightHighlightBorder)
                                    : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                                width: isSelected ? 1.5 : 0.8,
                              ),
                            ),
                            child: Text(
                              dayLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? (isDark ? Colors.black : Colors.white)
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Section 2: Jumlah Occurrence ────────────────────────────
            _buildSectionHeader(
              context,
              icon: Icons.looks_two_rounded,
              title: 'Langkah 2: Berapa Kali (Jumlah Jadwal)',
              color: catColor,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Banyaknya tanggal ke depan',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Akan dibuat N jadwal berurutan sesuai pola hari',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Counter buttons + input
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    onPressed: () {
                      final val = (int.tryParse(_countController.text) ?? 30) - 5;
                      if (val >= 1) {
                        setState(() {
                          _occurrenceCount = val;
                          _countController.text = val.toString();
                        });
                      }
                    },
                  ),
                  SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _countController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 6),
                        border: UnderlineInputBorder(),
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          _occurrenceCount = parsed;
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: catColor,
                    onPressed: () {
                      final val = (int.tryParse(_countController.text) ?? 30) + 5;
                      if (val <= 365) {
                        setState(() {
                          _occurrenceCount = val;
                          _countController.text = val.toString();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Section 3: Daftar Item Pool (Opsional) ──────────────────
            _buildSectionHeader(
              context,
              icon: Icons.looks_3_rounded,
              title: 'Langkah 3: Rotasi Item / Konten Acak (Opsional)',
              color: catColor,
            ),
            const SizedBox(height: 6),
            Text(
              'Isi daftar hal yang mau digilir (misal nama game, judul film, tugas kerja, materi belajar, dst). Kosongkan jika semua jadwal memakai nama yang sama.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _itemInputController,
                          focusNode: _itemFocusNode,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addItem(),
                          decoration: InputDecoration(
                            hintText: 'Contoh: nama game, judul film, tugas kerja, dst...',
                            hintStyle: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                                  : AppColors.lightTextSecondary.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: catColor, width: 1.2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tambah'),
                        style: FilledButton.styleFrom(
                          backgroundColor: catColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_items.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_items.length, (index) {
                        return Chip(
                          backgroundColor: isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground,
                          label: Text(_items[index]),
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          deleteIconColor: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          onDeleted: () => _removeItem(index),
                          side: BorderSide(
                            color: catColor.withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),
                  ] else ...[
                    const SizedBox(height: 10),
                    Text(
                      'Belum ada item. Jika dikosongkan, semua jadwal akan memakai nama kategori default.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
                            : AppColors.lightTextSecondary.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Section 4: Tipe Notifikasi ──────────────────────────────
            _buildSectionHeader(
              context,
              icon: Icons.looks_4_rounded,
              title: 'Langkah 4: Tipe Notifikasi',
              color: catColor,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildNotificationTypeCard(
                    context,
                    title: 'Notifikasi Biasa',
                    subtitle: 'Banner ringkas',
                    icon: Icons.notifications_none_rounded,
                    isSelected: _notificationType == NotificationType.notification,
                    onTap: () => setState(
                      () => _notificationType = NotificationType.notification,
                    ),
                    activeColor: catColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNotificationTypeCard(
                    context,
                    title: 'Alarm Penuh',
                    subtitle: 'Layar penuh & dering',
                    icon: Icons.alarm_rounded,
                    isSelected: _notificationType == NotificationType.fullAlarm,
                    onTap: () => setState(
                      () => _notificationType = NotificationType.fullAlarm,
                    ),
                    activeColor: catColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Tombol Generate ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _generate,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  'Generate ${_countController.text} Jadwal (Lanjut ke Review)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: catColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationTypeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.12)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? activeColor
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : null,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
