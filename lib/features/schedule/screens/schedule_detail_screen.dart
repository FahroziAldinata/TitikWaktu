import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ScheduleDetailScreen extends ConsumerWidget {
  final String scheduleId;
  
  const ScheduleDetailScreen({super.key, required this.scheduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement schedule detail view
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Jadwal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/edit/$scheduleId');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Schedule Detail - Coming Soon'),
      ),
    );
  }
}
