import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/providers/schedule_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(dailySchedulesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Titik Waktu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // TODO: Navigate to weekly view
            },
          ),
        ],
      ),
      body: schedulesAsync.when(
        data: (schedules) {
          if (schedules.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada jadwal hari ini',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tekan + untuk menambah jadwal baru',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: schedule.color != null
                        ? Color(int.parse(schedule.color!.replaceFirst('#', '0xFF')))
                        : Theme.of(context).colorScheme.primary,
                    child: Icon(
                      schedule.notificationType == NotificationType.fullAlarm
                          ? Icons.alarm
                          : Icons.notifications,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    schedule.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: Switch(
                    value: schedule.isActive,
                    onChanged: (value) {
                      ref.read(scheduleListProvider.notifier).toggleSchedule(schedule.id);
                    },
                  ),
                  onTap: () {
                    context.push('/schedule/${schedule.id}');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
