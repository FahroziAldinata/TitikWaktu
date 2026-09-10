import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rrule/rrule.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/providers/category_provider.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:titik_waktu/models/schedule_enums.dart';
import 'package:titik_waktu/theme/app_colors.dart';
import 'package:titik_waktu/utils/date_format_helper.dart';
import 'package:titik_waktu/utils/recurrence_helper.dart';

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
  final _intervalController = TextEditingController(text: '1');

  late TimeOfDay _selectedTime;
  DateTime _selectedDate = DateTime.now();
  NotificationType _notificationType = NotificationType.notification;
  RecurrenceType _recurrenceType = RecurrenceType.once;
  int? _selectedCategoryId;
  int? _selectedColor;
  bool _isActive = true;

  // Custom recurrence options
  int _interval = 1;
  Set<int> _selectedWeekdays = {DateTime.now().weekday}; // 1 = Monday .. 7 = Sunday
  MonthlyPatternType _monthlyPattern = MonthlyPatternType.dayOfMonth;
  int _dayOfMonth = DateTime.now().day;
  int _nthWeekdayOrdinal = 1; // 1..4, -1 for last
  int _nthWeekday = DateTime.now().weekday; // 1 = Monday .. 7 = Sunday

  @override
  void initState() {
    super.initState();
    final defaultTime = DateTime.now().add(const Duration(minutes: 2));
    _selectedTime = TimeOfDay(hour: defaultTime.hour, minute: defaultTime.minute);
    _dayOfMonth = _selectedDate.day;
    _selectedWeekdays = {_selectedDate.weekday};
    _nthWeekday = _selectedDate.weekday;
    _intervalController.text = '1';

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
        int intervalVal = 1;
        Set<int> weekdays = {schedule.startDate?.weekday ?? DateTime.now().weekday};
        MonthlyPatternType monthlyPat = MonthlyPatternType.dayOfMonth;
        int dom = schedule.startDate?.day ?? DateTime.now().day;
        int nthOrd = 1;
        int nthDay = schedule.startDate?.weekday ?? DateTime.now().weekday;

        if (schedule.recurrenceRule != null && schedule.recurrenceRule!.isNotEmpty) {
          try {
            final rrule = RecurrenceRule.fromString(schedule.recurrenceRule!);
            intervalVal = rrule.interval ?? 1;
            switch (rrule.frequency) {
              case Frequency.daily:
                recType = RecurrenceType.daily;
                break;
              case Frequency.weekly:
                recType = RecurrenceType.weekly;
                if (rrule.byWeekDays.isNotEmpty) {
                  weekdays = rrule.byWeekDays.map((d) => d.day).toSet();
                }
                break;
              case Frequency.monthly:
                recType = RecurrenceType.monthly;
                if (rrule.byMonthDays.isNotEmpty) {
                  monthlyPat = MonthlyPatternType.dayOfMonth;
                  dom = rrule.byMonthDays.first;
                } else if (rrule.byWeekDays.isNotEmpty) {
                  monthlyPat = MonthlyPatternType.nthWeekday;
                  final byWeekDay = rrule.byWeekDays.first;
                  nthDay = byWeekDay.day;
                  nthOrd = byWeekDay.occurrence ?? 1;
                }
                break;
              default:
                recType = RecurrenceType.once;
            }
          } catch (_) {
            recType = RecurrenceType.once;
          }
        } else {
          recType = RecurrenceType.fromValue(schedule.recurrenceType);
        }

        setState(() {
          _titleController.text = schedule.title;
          _descriptionController.text = schedule.description ?? '';
          _selectedTime = TimeOfDay.fromDateTime(schedule.time);
          _selectedDate = schedule.startDate ?? DateTime.now();
          _notificationType = NotificationType.fromValue(schedule.notificationType);
          _recurrenceType = recType;
          _selectedCategoryId = schedule.categoryId;
          _selectedColor = schedule.color;
          _isActive = schedule.isActive;
          _interval = intervalVal;
          _intervalController.text = intervalVal.toString();
          _selectedWeekdays = weekdays;
          _monthlyPattern = monthlyPat;
          _dayOfMonth = dom;
          _nthWeekdayOrdinal = nthOrd;
          _nthWeekday = nthDay;
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
    _intervalController.dispose();
    super.dispose();
  }

  void _onIntervalChanged(String val) {
    final parsed = int.tryParse(val);
    if (parsed != null && parsed > 0) {
      setState(() => _interval = parsed);
    }
  }

  void _incrementInterval() {
    setState(() {
      _interval++;
      _intervalController.text = _interval.toString();
    });
  }

  void _decrementInterval() {
    if (_interval > 1) {
      setState(() {
        _interval--;
        _intervalController.text = _interval.toString();
      });
    }
  }

  String _getPreviewText() {
    return RecurrenceHelper.formatHumanReadable(
      recurrenceType: _recurrenceType,
      startDate: _selectedDate,
      interval: _interval,
      selectedWeekdays: _selectedWeekdays.toList(),
      monthlyPattern: _monthlyPattern,
      dayOfMonth: _dayOfMonth,
      nthOrdinal: _nthWeekdayOrdinal,
      nthWeekday: _nthWeekday,
    );
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
            // Title Input
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

            // Description Input
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                hintText: 'Tambahkan detail atau instruksi...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 28),

            // Waktu Besar & Interaktif
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

            // Tipe Notifikasi
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
                    setState(() {
                      _selectedCategoryId = value;
                      if (value != null) {
                        final cat = categories.cast<Category?>().firstWhere(
                              (c) => c?.id == value,
                              orElse: () => null,
                            );
                        if (cat != null) {
                          _selectedColor = AppColors.parseCategoryColor(cat.colorHex).toARGB32();
                        }
                      }
                    });
                  },
                );
              },
              loading: () => const SizedBox(height: 48, child: LinearProgressIndicator()),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 20),

            // WARNA JADWAL SECTION
            Text(
              'WARNA JADWAL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            _buildColorSelector(isDark),
            const SizedBox(height: 24),

            // PENGULANGAN SECTION
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
              key: ValueKey(_recurrenceType),
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
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _recurrenceType = value);
                }
              },
            ),

            // Custom Interval Options
            if (_recurrenceType != RecurrenceType.once && _recurrenceType != RecurrenceType.none) ...[
              const SizedBox(height: 16),
              _buildIntervalInput(isDark),
            ],

            // Weekly Day Selector
            if (_recurrenceType == RecurrenceType.weekly) ...[
              const SizedBox(height: 16),
              _buildWeeklyDaySelector(isDark),
            ],

            // Monthly Pattern Selector
            if (_recurrenceType == RecurrenceType.monthly) ...[
              const SizedBox(height: 16),
              _buildMonthlyPatternSelector(isDark),
            ],

            // Human-readable preview card
            const SizedBox(height: 16),
            _buildRecurrencePreviewCard(isDark),

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

  static const List<Color> _presetColors = [
    AppColors.categoryCoral,
    AppColors.categoryAmber,
    AppColors.categoryGreen,
    AppColors.categoryTeal,
    AppColors.categoryBlue,
    AppColors.categoryPink,
    Color(0xFF8E24AA), // Purple
    Color(0xFF3949AB), // Indigo
  ];

  Widget _buildColorSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        children: _presetColors.map((color) {
          final colorVal = color.toARGB32();
          final isSelected = _selectedColor == colorVal;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedColor = colorVal);
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIntervalInput(bool isDark) {
    String unitLabel = 'hari';
    if (_recurrenceType == RecurrenceType.weekly) unitLabel = 'minggu';
    if (_recurrenceType == RecurrenceType.monthly) unitLabel = 'bulan';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            'Ulangi setiap:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 22),
                onPressed: _decrementInterval,
                tooltip: 'Kurangi',
              ),
              SizedBox(
                width: 44,
                child: TextFormField(
                  controller: _intervalController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onIntervalChanged,
                  validator: (val) {
                    final n = int.tryParse(val ?? '');
                    if (n == null || n <= 0) {
                      return 'Harus > 0';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 22),
                onPressed: _incrementInterval,
                tooltip: 'Tambah',
              ),
              const SizedBox(width: 4),
              Text(
                unitLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyDaySelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HARI PENGULANGAN',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final weekday = index + 1; // 1 = Monday .. 7 = Sunday
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
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator)
                      : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? AppColors.amberDarkHighlightBorder : AppColors.amberLightHighlightBorder)
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Text(
                  dayLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? (isDark ? Colors.black : Colors.white)
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMonthlyPatternSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode 1: Tanggal Spesifik
          InkWell(
            onTap: () {
              setState(() => _monthlyPattern = MonthlyPatternType.dayOfMonth);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    _monthlyPattern == MonthlyPatternType.dayOfMonth
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 20,
                    color: _monthlyPattern == MonthlyPatternType.dayOfMonth
                        ? (isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator)
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                  const SizedBox(width: 8),
                  const Text('Pada tanggal: ', style: TextStyle(fontSize: 13)),
                  DropdownButton<int>(
                    value: _dayOfMonth,
                    underline: const SizedBox(),
                    items: List.generate(31, (index) {
                      final d = index + 1;
                      return DropdownMenuItem(value: d, child: Text('$d'));
                    }),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _dayOfMonth = val;
                          _monthlyPattern = MonthlyPatternType.dayOfMonth;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 8),

          // Mode 2: N-th Weekday (misal: "Senin pertama")
          InkWell(
            onTap: () {
              setState(() => _monthlyPattern = MonthlyPatternType.nthWeekday);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    _monthlyPattern == MonthlyPatternType.nthWeekday
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 20,
                    color: _monthlyPattern == MonthlyPatternType.nthWeekday
                        ? (isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator)
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Pada: ', style: TextStyle(fontSize: 13)),
                        DropdownButton<int>(
                          value: _nthWeekday,
                          underline: const SizedBox(),
                          items: List.generate(7, (idx) {
                            return DropdownMenuItem(
                              value: idx + 1,
                              child: Text(RecurrenceHelper.dayFullNames[idx], style: const TextStyle(fontSize: 13)),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _nthWeekday = val;
                                _monthlyPattern = MonthlyPatternType.nthWeekday;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        DropdownButton<int>(
                          value: _nthWeekdayOrdinal,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('pertama', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 2, child: Text('kedua', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 3, child: Text('ketiga', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 4, child: Text('keempat', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: -1, child: Text('terakhir', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _nthWeekdayOrdinal = val;
                                _monthlyPattern = MonthlyPatternType.nthWeekday;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurrencePreviewCard(bool isDark) {
    final previewText = _getPreviewText();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.amberDarkHighlightBg : AppColors.amberLightHighlightBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.amberDarkHighlightBorder : AppColors.amberLightHighlightBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.autorenew_rounded,
            size: 20,
            color: isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              previewText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.amberDarkHighlightTitle : AppColors.amberLightHighlightTitle,
              ),
            ),
          ),
        ],
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
      setState(() {
        _selectedDate = picked;
        _dayOfMonth = picked.day;
        _nthWeekday = picked.weekday;
        if (_selectedWeekdays.isEmpty) {
          _selectedWeekdays = {picked.weekday};
        }
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      final scheduleIdInt = int.tryParse(widget.scheduleId ?? '') ?? 0;

      final rruleString = RecurrenceHelper.buildRruleString(
        type: _recurrenceType,
        interval: _interval,
        selectedWeekdays: _selectedWeekdays.toList(),
        monthlyPattern: _monthlyPattern,
        dayOfMonth: _dayOfMonth,
        nthWeekdayOrdinal: _nthWeekdayOrdinal,
        nthWeekday: _nthWeekday,
      );

      final schedule = Schedule(
        id: scheduleIdInt,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        time: DateTime(0, 0, 0, _selectedTime.hour, _selectedTime.minute),
        startDate: _selectedDate,
        notificationType: _notificationType.value,
        color: _selectedColor ?? 0xFFFFFFFF,
        recurrenceType: _recurrenceType.value,
        recurrenceRule: rruleString,
        interval: _interval,
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
