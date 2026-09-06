import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/providers/permission_provider.dart';
import 'package:titik_waktu/services/permission_service.dart';
import 'package:titik_waktu/features/onboarding/widgets/permission_card.dart';
import 'package:titik_waktu/features/onboarding/widgets/permission_rationale_dialog.dart';

class PermissionOnboardingScreen extends ConsumerStatefulWidget {
  const PermissionOnboardingScreen({super.key});

  @override
  ConsumerState<PermissionOnboardingScreen> createState() =>
      _PermissionOnboardingScreenState();
}

class _PermissionOnboardingScreenState
    extends ConsumerState<PermissionOnboardingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(permissionProvider.notifier).refreshPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(permissionProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitDialog(context);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: permissionState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      _buildHeader(colorScheme),
                      const SizedBox(height: 40),
                      _buildPermissionList(permissionState, colorScheme),
                      const SizedBox(height: 32),
                      _buildSkipButton(permissionState),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.alarm,
            size: 40,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Izin yang Diperlukan',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Titik Waktu memerlukan beberapa izin agar alarm dapat berfungsi dengan baik.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionList(
    PermissionState permissionState,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        PermissionCard(
          title: 'Notifikasi',
          description:
              'Terima pengingat saat jadwal kegiatan akan dimulai.',
          icon: Icons.notifications_active,
          isGranted: permissionState.notificationGranted,
          isRequired: true,
          onRequest: () => _handleRequestNotification(),
        ),
        PermissionCard(
          title: 'Alarm Tepat Waktu',
          description:
              'Alarm berbunyi tepat sesuai jadwal yang ditentukan.',
          icon: Icons.access_alarm,
          isGranted: permissionState.exactAlarmGranted,
          isRequired: true,
          onRequest: () => _handleRequestExactAlarm(),
        ),
        PermissionCard(
          title: 'Nonaktifkan Optimasi Baterai',
          description:
              'Alarm tetap berbunyi meskipun aplikasi di latar belakang.',
          icon: Icons.battery_saver,
          isGranted: permissionState.batteryOptimizationGranted,
          isOptional: true,
          onRequest: () => _handleRequestBatteryOptimization(),
        ),
      ],
    );
  }

  Future<void> _handleRequestNotification() async {
    final rationale = getPermissionRationale(AppPermission.notification);
    final shouldProceed = await PermissionRationaleDialog.show(
      context,
      title: rationale['title'] as String,
      description: rationale['description'] as String,
      featureImpact: rationale['featureImpact'] as String,
      icon: rationale['icon'] as IconData,
    );

    if (shouldProceed == true && mounted) {
      final result =
          await ref.read(permissionProvider.notifier).requestNotificationPermission();

      if (result.isPermanentlyDenied && mounted) {
        final openSettings = await PermissionPermanentlyDeniedDialog.show(
          context,
          permissionName: 'Notifikasi',
        );
        if (openSettings) {
          await ref.read(permissionProvider.notifier).openAppSettingsPage();
          await ref.read(permissionProvider.notifier).refreshPermissions();
        }
      }
    }
  }

  Future<void> _handleRequestExactAlarm() async {
    final rationale = getPermissionRationale(AppPermission.exactAlarm);
    final shouldProceed = await PermissionRationaleDialog.show(
      context,
      title: rationale['title'] as String,
      description: rationale['description'] as String,
      featureImpact: rationale['featureImpact'] as String,
      icon: rationale['icon'] as IconData,
    );

    if (shouldProceed == true && mounted) {
      final result =
          await ref.read(permissionProvider.notifier).requestExactAlarmPermission();

      if (result.isPermanentlyDenied && mounted) {
        final openSettings = await PermissionPermanentlyDeniedDialog.show(
          context,
          permissionName: 'Alarm Tepat Waktu',
        );
        if (openSettings) {
          await ref.read(permissionProvider.notifier).openAppSettingsPage();
          await ref.read(permissionProvider.notifier).refreshPermissions();
        }
      }
    }
  }

  Future<void> _handleRequestBatteryOptimization() async {
    final rationale = getPermissionRationale(AppPermission.batteryOptimization);
    final shouldProceed = await PermissionRationaleDialog.show(
      context,
      title: rationale['title'] as String,
      description: rationale['description'] as String,
      featureImpact: rationale['featureImpact'] as String,
      icon: rationale['icon'] as IconData,
    );

    if (shouldProceed == true && mounted) {
      final result =
          await ref.read(permissionProvider.notifier).requestBatteryOptimization();

      if (!result.isGranted && mounted) {
        final shouldOpenSettings = await PermissionPermanentlyDeniedDialog.show(
          context,
          permissionName: 'Optimasi Baterai',
        );
        if (shouldOpenSettings) {
          await ref.read(permissionProvider.notifier).openBatterySettings();
        }
      }
    }
  }

  Widget _buildSkipButton(PermissionState permissionState) {
    final colorScheme = Theme.of(context).colorScheme;

    if (permissionState.allCriticalGranted) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => _navigateToHome(),
          child: const Text('Mulai Gunakan'),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _navigateToHome(),
            child: const Text('Lewati untuk Sekarang'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Anda dapat mengatur izin nanti di Pengaturan',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _navigateToHome() {
    ref.read(permissionProvider.notifier).completeOnboarding();
    context.go('/');
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Izin?'),
        content: const Text(
          'Anda dapat melanjutkan tanpa memberikan izin, '
          'tetapi alarm mungkin tidak berfungsi dengan baik.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tetap di Sini'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToHome();
            },
            child: const Text('Lewati'),
          ),
        ],
      ),
    );
  }
}
