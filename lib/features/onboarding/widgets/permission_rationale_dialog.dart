import 'package:flutter/material.dart';
import 'package:titik_waktu/services/permission_service.dart';

class PermissionRationaleDialog extends StatelessWidget {
  final String title;
  final String description;
  final String featureImpact;
  final IconData icon;

  const PermissionRationaleDialog({
    super.key,
    required this.title,
    required this.description,
    required this.featureImpact,
    required this.icon,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String description,
    required String featureImpact,
    required IconData icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PermissionRationaleDialog(
        title: title,
        description: description,
        featureImpact: featureImpact,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(icon, size: 48, color: colorScheme.primary),
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    featureImpact,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Nanti Saja'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Beri Izin'),
        ),
      ],
    );
  }
}

class PermissionPermanentlyDeniedDialog extends StatelessWidget {
  final String permissionName;

  const PermissionPermanentlyDeniedDialog({
    super.key,
    required this.permissionName,
  });

  static Future<bool> show(
    BuildContext context, {
    required String permissionName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          PermissionPermanentlyDeniedDialog(permissionName: permissionName),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.block, size: 48, color: Colors.orange),
      title: const Text('Izin Ditolak Permanen'),
      content: Text(
        'Izin $permissionName telah ditolak secara permanen. '
        'Untuk mengaktifkannya, buka Pengaturan Aplikasi.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Buka Pengaturan'),
        ),
      ],
    );
  }
}

class PermissionRequiredForAlarmDialog extends StatelessWidget {
  const PermissionRequiredForAlarmDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PermissionRequiredForAlarmDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(Icons.alarm_off, size: 48, color: colorScheme.error),
      title: const Text('Alarm Tidak Dapat Berfungsi'),
      content: const Text(
        'Tanpa izin notifikasi dan alarm tepat waktu, '
        'aplikasi tidak dapat mengingatkan Anda. '
        'Izin ini sangat diperlukan agar alarm dapat berbunyi tepat waktu.',
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Mengerti'),
        ),
      ],
    );
  }
}

Map<String, dynamic> getPermissionRationale(AppPermission permission) {
  switch (permission) {
    case AppPermission.notification:
      return {
        'title': 'Izin Notifikasi',
        'description':
            'Titik Waktu memerlukan akses notifikasi untuk mengingatkan Anda '
            'saat jadwal kegiatan akan dimulai.',
        'featureImpact':
            'Tanpa izin ini, Anda tidak akan menerima pengingat apapun.',
        'icon': Icons.notifications_active,
      };
    case AppPermission.exactAlarm:
      return {
        'title': 'Alarm Tepat Waktu',
        'description':
            'Titik Waktu memerlukan izin untuk menjadwalkan alarm tepat waktu '
            'agar pengingat berbunyi sesuai jadwal yang ditentukan.',
        'featureImpact':
            'Alarm mungkin tidak berbunyi tepat waktu atau terlambat.',
        'icon': Icons.access_alarm,
      };
    case AppPermission.batteryOptimization:
      return {
        'title': 'Nonaktifkan Optimasi Baterai',
        'description':
            'Titik Waktu memerlukan pengecualian dari optimasi baterai '
            'agar alarm dapat berbunyi meskipun aplikasi berjalan di latar belakang.',
        'featureImpact':
            'Sistem bisa menghentikan alarm saat aplikasi dijeda oleh baterai.',
        'icon': Icons.battery_saver,
      };
    case AppPermission.ignoreBatteryOptimization:
      return {
        'title': 'Nonaktifkan Optimasi Baterai',
        'description':
            'Titik Waktu memerlukan pengecualian dari optimasi baterai '
            'agar alarm dapat berbunyi meskipun aplikasi berjalan di latar belakang.',
        'featureImpact':
            'Sistem bisa menghentikan alarm saat aplikasi dijeda oleh baterai.',
        'icon': Icons.battery_saver,
      };
  }
}
