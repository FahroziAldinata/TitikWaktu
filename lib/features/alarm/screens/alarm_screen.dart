import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/providers/history_provider.dart';

class AlarmScreen extends ConsumerStatefulWidget {
  final String scheduleId;
  
  const AlarmScreen({super.key, required this.scheduleId});

  @override
  ConsumerState<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends ConsumerState<AlarmScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Record alarm triggered event
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyRepositoryProvider).addLog(
        '${HistoryLogHelper.actionAlarmTriggered}: Schedule #${widget.scheduleId}',
      );
    });
  }
  
  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(
              Icons.alarm,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 32),
            Text(
              'Alarm',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Schedule: ${widget.scheduleId}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AlarmButton(
                    icon: Icons.snooze,
                    label: 'Tunda',
                    onTap: _snoozeAlarm,
                  ),
                  _AlarmButton(
                    icon: Icons.stop,
                    label: 'Matikan',
                    onTap: _dismissAlarm,
                    isPrimary: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _snoozeAlarm() {
    ref.read(historyRepositoryProvider).addLog(
      '${HistoryLogHelper.actionAlarmSnoozed}: Schedule #${widget.scheduleId} (5 menit)',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alarm ditunda 5 menit')),
    );
  }
  
  void _dismissAlarm() {
    ref.read(historyRepositoryProvider).addLog(
      '${HistoryLogHelper.actionAlarmDismissed}: Schedule #${widget.scheduleId}',
    );
    context.pop();
  }
}

class _AlarmButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  
  const _AlarmButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrimary ? Colors.red : Colors.white24,
            ),
            child: Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
