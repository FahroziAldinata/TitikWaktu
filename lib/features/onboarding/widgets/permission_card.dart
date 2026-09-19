import 'package:flutter/material.dart';

import 'package:titik_waktu/theme/app_colors.dart';

class PermissionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isGranted;
  final bool isRequired;
  final bool isOptional;
  final VoidCallback? onRequest;

  const PermissionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isGranted,
    this.isRequired = false,
    this.isOptional = false,
    this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isGranted
                    ? (isDark
                        ? AppColors.statusSuccessDarkContainer
                        : AppColors.statusSuccessLightContainer)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isGranted
                      ? (isDark
                          ? AppColors.statusSuccessDarkBorder
                          : AppColors.statusSuccessLightBorder)
                      : colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
              child: Icon(
                isGranted ? Icons.check_circle_rounded : icon,
                size: 24,
                color: isGranted
                    ? AppColors.statusSuccess
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.statusErrorDarkContainer
                                : AppColors.statusErrorLightContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wajib',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.statusError,
                            ),
                          ),
                        ),
                      if (isOptional)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Opsional',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isGranted)
              const Icon(Icons.check_circle_rounded, color: AppColors.statusSuccess)
            else if (onRequest != null)
              FilledButton(
                onPressed: onRequest,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Izinkan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}
