import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/features/permissions/widgets/permission_widgets.dart';
import 'package:titik_waktu/providers/permission_provider.dart';

/// Screen untuk mengelola dan meminta permission
class PermissionManagementScreen extends ConsumerStatefulWidget {
  const PermissionManagementScreen({super.key});

  @override
  ConsumerState<PermissionManagementScreen> createState() =>
      _PermissionManagementScreenState();
}

class _PermissionManagementScreenState
    extends ConsumerState<PermissionManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(permissionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Izin Aplikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.go('/permissions/onboarding'),
          ),
        ],
      ),
      body: permissionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Izin Aplikasi',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pastikan semua izin aktif untuk pengalaman alarm yang optimal',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  _buildSummary(permissionState),

                  const SizedBox(height: 24),

                  Text(
                    'Detail Izin',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        PermissionTile(
                          title: 'Alarm Tepat Waktu',
                          subtitle:
                              'Mengizinkan alarm yang tepat waktu bahkan saat background',
                          icon: Icons.alarm_rounded,
                          isGranted: permissionState.exactAlarmGranted,
                          onTap: _requestExactAlarm,
                        ),
                        const SizedBox(height: 8),
                        PermissionTile(
                          title: 'Optimasi Baterai',
                          subtitle:
                              'Nonaktifkan pembatasan background untuk reliable alarm',
                          icon: Icons.battery_charging_full_rounded,
                          isGranted: permissionState.batteryOptimizationGranted,
                          onTap: _requestBatteryOptimization,
                        ),
                        const SizedBox(height: 8),
                        PermissionTile(
                          title: 'Notifikasi',
                          subtitle: 'Mengizinkan notifikasi jadwal dan alarm',
                          icon: Icons.notifications_rounded,
                          isGranted: permissionState.notificationGranted,
                          onTap: _requestNotification,
                        ),
                      ],
                    ),
                  ),

                  if (!permissionState.allGranted) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Izin Penting',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  'Alarm mungkin tidak berfungsi jika izin tidak aktif',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSummary(PermissionState permissionState) {
    final colorScheme = Theme.of(context).colorScheme;

    final missing = <String>[
      if (!permissionState.notificationGranted) 'Notifikasi',
      if (!permissionState.exactAlarmGranted) 'Alarm Tepat Waktu',
      if (!permissionState.batteryOptimizationGranted) 'Optimasi Baterai',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: permissionState.allGranted
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            permissionState.allGranted ? Icons.check_circle_rounded : Icons.warning_rounded,
            size: 32,
            color: permissionState.allGranted
                ? colorScheme.onPrimaryContainer
                : colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permissionState.allGranted
                      ? 'Semua Izin Aktif'
                      : 'Beberapa Izin Belum Aktif',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (!permissionState.allGranted) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Izin yang diperlukan: ${missing.join(", ")}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (!permissionState.allGranted)
            FilledButton(
              onPressed: _requestAllPermissions,
              child: const Text('Setup'),
            ),
        ],
      ),
    );
  }

  void _requestAllPermissions() {
    final notifier = ref.read(permissionProvider.notifier);
    notifier.requestNotificationPermission();
    notifier.requestExactAlarmPermission();
    notifier.requestBatteryOptimization();
  }

  void _requestExactAlarm() async {
    final service = ref.read(permissionServiceProvider);
    await service.requestExactAlarmPermission();
    ref.read(permissionProvider.notifier).refreshPermissions();
  }

  void _requestBatteryOptimization() async {
    final service = ref.read(permissionServiceProvider);
    await service.requestIgnoreBatteryOptimization();
    ref.read(permissionProvider.notifier).refreshPermissions();
  }

  void _requestNotification() async {
    final service = ref.read(permissionServiceProvider);
    await service.requestNotificationPermission();
    ref.read(permissionProvider.notifier).refreshPermissions();
  }
}