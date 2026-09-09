import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rrule/rrule.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/providers/category_provider.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/theme/app_colors.dart';
import 'package:titik_waktu/utils/date_format_helper.dart';

class AddScheduleScreen extends ConsumerStatefulWidget {
  final String? scheduleId;

  const AddScheduleScreen({super.key, this.scheduleId});

  @override
  ConsumerState<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends ConsumerState<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late TimeOfDay _selectedTime;
  DateTime _selectedDate = DateTime.now();
  NotificationType _notificationType = NotificationType.notification;
  RecurrenceType _recurrenceType = RecurrenceType.once;
  int? _selectedCategoryId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final defaultTime = DateTime.now().add(const Duration(minutes: 2));
    _selectedTime = TimeOfDay(hour: defaultTime.hour, minute: defaultTime.minute);
    if (widget.scheduleId != null) {
      _loadSchedule();
    }
  }

  Future<void> _loadSchedule() async {
    final scheduleIdInt = int.tryParse(widget.scheduleId ?? '');
    if (scheduleIdInt == null) return;

    try {
      final repo = ref.read(scheduleRepositoryProvider);
      final schedule = await repo.getScheduleById(scheduleIdInt);
      if (schedule != null && mounted) {
        RecurrenceType recType = RecurrenceType.once;
        if (schedule.recurrenceRule != null && schedule.recurrenceRule!.isNotEmpty) {
          try {
            final rrule = RecurrenceRule.fromString(schedule.recurrenceRule!);
            switch (rrule.frequency) {
              case Frequency.daily:
                recType = RecurrenceType.daily;
                break;
              case Frequency.weekly:
                recType = RecurrenceType.weekly;
                break;
              case Frequency.monthly:
                recType = RecurrenceType.monthly;
                break;
              default:
                recType = RecurrenceType.once;
            }
          } catch (_) {
            recType = RecurrenceType.once;
          }
        }

        setState(() {
          _titleController.text = schedule.title;
          _descriptionController.text = schedule.description ?? '';
          _selectedTime = TimeOfDay.fromDateTime(schedule.time);
          _selectedDate = schedule.startDate ?? DateTime.now();
          _notificationType = NotificationType.fromValue(schedule.notificationType);
          _recurrenceType = recType;
          _selectedCategoryId = schedule.categoryId;
          _isActive = schedule.isActive;
        });
      }
    } catch (e) {
      debugPrint('Error loading schedule: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoryListProvider);

    final timeString =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    final dateString = AppDateFormatter.formatFullDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scheduleId != null ? 'Edit Jadwal' : 'Tambah Jadwal'),
        actions: [
          if (widget.scheduleId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Hapus Jadwal',
              onPressed: _deleteSchedule,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Title Input (Underline Style)
            TextFormField(
              controller: _titleController,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Judul Jadwal',
                hintText: 'Contoh: Minum Obat, Meeting...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul jadwal tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description Input (Underline Style)
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                hintText: 'Tambahkan detail atau instruksi...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 28),

            // Waktu Besar & Interaktif (38-40px)
            Text(
              'WAKTU',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeString,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -1.0,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 26),
                          tooltip: '-1 Menit',
                          onPressed: () {
                            final dt = DateTime(2026, 1, 1, _selectedTime.hour, _selectedTime.minute)
                                .subtract(const Duration(minutes: 1));
                            setState(() => _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 26),
                          tooltip: '+1 Menit',
                          onPressed: () {
                            final dt = DateTime(2026, 1, 1, _selectedTime.hour, _selectedTime.minute)
                                .add(const Duration(minutes: 1));
                            setState(() => _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tanggal Mulai
            Text(
              'TANGGAL MULAI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateString,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tipe Notifikasi: Dua Kartu Toggle Side-by-Side dengan Highlight Amber
            Text(
              'TIPE NOTIFIKASI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildNotificationToggleCard(
                    title: 'Notifikasi',
                    subtitle: 'Banner & Suara Singkat',
                    icon: Icons.notifications_none,
                    isSelected: _notificationType == NotificationType.notification,
                    isDark: isDark,
                    onTap: () {
                      setState(() => _notificationType = NotificationType.notification);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNotificationToggleCard(
                    title: 'Alarm Penuh',
                    subtitle: 'Layar Penuh & Suara Kuat',
                    icon: Icons.alarm,
                    isSelected: _notificationType == NotificationType.fullAlarm,
                    isDark: isDark,
                    onTap: () {
                      setState(() => _notificationType = NotificationType.fullAlarm);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Kategori Selector
            Text(
              'KATEGORI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            categoriesAsync.when(
              data: (categories) {
                return DropdownButtonFormField<int?>(
                  initialValue: _selectedCategoryId,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 0.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 0.5,
                      ),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Tanpa Kategori'),
                    ),
                    ...categories.map((c) {
                      final cColor = AppColors.parseCategoryColor(c.colorHex);
                      return DropdownMenuItem<int?>(
                        value: c.id,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: cColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(c.name),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategoryId = value);
                  },
                );
              },
              loading: () => const SizedBox(height: 48, child: LinearProgressIndicator()),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 24),

            // Pengulangan (Dropdown)
            Text(
              'PENGULANGAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<RecurrenceType>(
              initialValue: _recurrenceType,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
              ),
              items: const [
                DropdownMenuItem(value: RecurrenceType.once, child: Text('Sekali')),
                DropdownMenuItem(value: RecurrenceType.daily, child: Text('Harian')),
                DropdownMenuItem(value: RecurrenceType.weekly, child: Text('Mingguan')),
                DropdownMenuItem(value: RecurrenceType.monthly, child: Text('Bulanan')),
                DropdownMenuItem(value: RecurrenceType.customInterval, child: Text('Custom Interval')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _recurrenceType = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Switch Aktif
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Aktifkan Jadwal', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Jadwal akan memicu notifikasi/alarm'),
              value: _isActive,
              activeThumbColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _saveSchedule,
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              foregroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Simpan Jadwal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationToggleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    Color bg;
    Color border;
    Color iconColor;
    Color titleColor;
    Color subtitleColor;

    if (isSelected) {
      bg = isDark ? AppColors.amberDarkHighlightBg : AppColors.amberLightHighlightBg;
      border = isDark ? AppColors.amberDarkHighlightBorder : AppColors.amberLightHighlightBorder;
      iconColor = isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator;
      titleColor = isDark ? AppColors.amberDarkHighlightTitle : AppColors.amberLightHighlightTitle;
      subtitleColor = isDark ? AppColors.amberDarkHighlightSubtitle : AppColors.amberLightHighlightSubtitle;
    } else {
      bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
      border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
      iconColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
      titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
      subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: isSelected ? 1.5 : 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: subtitleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      final scheduleIdInt = int.tryParse(widget.scheduleId ?? '') ?? 0;

      String? rruleString;
      switch (_recurrenceType) {
        case RecurrenceType.daily:
          rruleString = 'RRULE:FREQ=DAILY;INTERVAL=1';
          break;
        case RecurrenceType.weekly:
          rruleString = 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR,SA,SU';
          break;
        case RecurrenceType.monthly:
          rruleString = 'RRULE:FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=${_selectedDate.day}';
          break;
        case RecurrenceType.once:
        case RecurrenceType.none:
        default:
          rruleString = null;
          break;
      }

      final schedule = Schedule(
        id: scheduleIdInt,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        time: DateTime(0, 0, 0, _selectedTime.hour, _selectedTime.minute),
        startDate: _selectedDate,
        notificationType: _notificationType.value,
        recurrenceType: _recurrenceType.value,
        recurrenceRule: rruleString,
        interval: 1,
        categoryId: _selectedCategoryId,
        isActive: _isActive,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.scheduleId != null && scheduleIdInt != 0) {
        await ref.read(scheduleListProvider.notifier).updateSchedule(schedule);
      } else {
        await ref.read(scheduleListProvider.notifier).addSchedule(schedule);
      }

      if (mounted) {
        context.pop();
      }
    }
  }

  Future<void> _deleteSchedule() async {
    final scheduleIdInt = int.tryParse(widget.scheduleId ?? '');
    if (scheduleIdInt == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: const Text('Jadwal akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(scheduleListProvider.notifier).deleteSchedule(scheduleIdInt);
      if (mounted) {
        context.pop();
      }
    }
  }
}
