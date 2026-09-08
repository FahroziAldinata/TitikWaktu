import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rrule/rrule.dart';
import 'package:titik_waktu/database/database.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';
import 'package:titik_waktu/models/schedule_enums.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scheduleId != null ? 'Edit Jadwal' : 'Tambah Jadwal'),
        actions: [
          if (widget.scheduleId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSchedule,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Kegiatan',
                hintText: 'Contoh: Minum Obat',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (Opsional)',
                hintText: 'Tambahkan catatan...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Waktu'),
              subtitle: Text(
                '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    tooltip: '-1 Menit',
                    onPressed: () {
                      final dt = DateTime(2026, 1, 1, _selectedTime.hour, _selectedTime.minute).subtract(const Duration(minutes: 1));
                      setState(() => _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: '+1 Menit',
                    onPressed: () {
                      final dt = DateTime(2026, 1, 1, _selectedTime.hour, _selectedTime.minute).add(const Duration(minutes: 1));
                      setState(() => _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute));
                    },
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: _selectTime,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal Mulai'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<NotificationType>(
              initialValue: _notificationType,
              decoration: const InputDecoration(
                labelText: 'Tipe Notifikasi',
              ),
              items: const [
                DropdownMenuItem(
                  value: NotificationType.notification,
                  child: Text('Notifikasi Biasa'),
                ),
                DropdownMenuItem(
                  value: NotificationType.fullAlarm,
                  child: Text('Alarm Penuh'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _notificationType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RecurrenceType>(
              initialValue: _recurrenceType,
              decoration: const InputDecoration(
                labelText: 'Pengulangan',
              ),
              items: const [
                DropdownMenuItem(
                  value: RecurrenceType.once,
                  child: Text('Sekali'),
                ),
                DropdownMenuItem(
                  value: RecurrenceType.daily,
                  child: Text('Harian'),
                ),
                DropdownMenuItem(
                  value: RecurrenceType.weekly,
                  child: Text('Mingguan'),
                ),
                DropdownMenuItem(
                  value: RecurrenceType.monthly,
                  child: Text('Bulanan'),
                ),
                DropdownMenuItem(
                  value: RecurrenceType.customInterval,
                  child: Text('Custom Interval'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _recurrenceType = value);
                }
              },
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Aktif'),
              subtitle: const Text('Jadwal akan mengirim notifikasi'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _saveSchedule,
            child: const Text('Simpan'),
          ),
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
      firstDate: DateTime.now(),
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
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        time: DateTime(0, 0, 0, _selectedTime.hour, _selectedTime.minute),
        startDate: _selectedDate,
        notificationType: _notificationType.value,
        recurrenceType: _recurrenceType.value,
        recurrenceRule: rruleString,
        interval: 1,
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
