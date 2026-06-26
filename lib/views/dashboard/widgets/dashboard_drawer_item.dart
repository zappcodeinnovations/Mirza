import 'package:flutter/material.dart';

import '../../../core/app_icons.dart';
import '../../../core/app_theme.dart';

class DashboardDrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const DashboardDrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: AppTheme.neonBlue),

      title: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),

      trailing: Icon(
        AppIcons.arrowForward,
        size: 16,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
      ),

      onTap: onTap,
    );
  }
}
