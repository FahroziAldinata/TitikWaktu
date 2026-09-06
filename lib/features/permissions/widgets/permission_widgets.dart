import 'package:flutter/material.dart';

class PermissionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isGranted;
  final VoidCallback onTap;

  const PermissionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isGranted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isGranted
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          child: Icon(
            icon,
            color: isGranted ? colorScheme.onPrimaryContainer : colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          isGranted ? Icons.check_circle_rounded : Icons.chevron_right,
          color: isGranted ? colorScheme.primary : colorScheme.outline,
        ),
        onTap: onTap,
      ),
    );
  }
}