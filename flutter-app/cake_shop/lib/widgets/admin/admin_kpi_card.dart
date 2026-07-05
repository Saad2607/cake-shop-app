import 'package:flutter/material.dart';
import '../../theme/admin_theme.dart';

class AdminKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sublabel;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const AdminKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.sublabel,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminTheme.surface,
      borderRadius: AdminTheme.radiusMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AdminTheme.radiusMd,
        child: Ink(
          width: 148,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: AdminTheme.radiusMd,
            border: Border.all(color: AdminTheme.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const Spacer(),
                  if (onTap != null)
                    const Icon(Icons.chevron_right_rounded, size: 18, color: AdminTheme.textSecondary),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: AdminTheme.kpiValue.copyWith(fontSize: 20),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AdminTheme.kpiLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (sublabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  sublabel!,
                  style: AdminTheme.kpiLabel.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AdminQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const AdminQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AdminTheme.surface,
        borderRadius: AdminTheme.radiusMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AdminTheme.radiusMd,
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: AdminTheme.radiusMd,
              border: Border.all(color: AdminTheme.border),
            ),
            child: Column(
              children: [
                Icon(icon, color: AdminTheme.accent, size: 24),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AdminTheme.kpiLabel.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminAlertBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? actionLabel;

  const AdminAlertBanner({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
    this.onTap,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: AdminTheme.radiusMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AdminTheme.radiusMd,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: AdminTheme.radiusMd,
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AdminTheme.kpiLabel.copyWith(
                    color: color.withValues(alpha: 0.95),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (actionLabel != null)
                Text(
                  actionLabel!,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
