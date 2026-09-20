import 'package:flutter/material.dart';
import 'package:titik_waktu/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_outlined,
              size: 52,
              color: textMuted.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Pengaturan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Coming soon',
              style: theme.textTheme.bodySmall?.copyWith(
                color: textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
