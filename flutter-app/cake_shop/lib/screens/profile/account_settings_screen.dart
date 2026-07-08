import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/delivery_address_sheet.dart';
import '../../widgets/edit_profile_sheet.dart';
import 'help_support_screen.dart';
import 'server_settings_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _notificationTile(context),
          const SizedBox(height: 8),
          _tile(
            context,
            icon: Icons.edit_outlined,
            title: 'Edit profile',
            subtitle: 'Name and phone number',
            onTap: () => _editProfile(context, user.name, user.phone),
          ),
          const SizedBox(height: 8),
          _tile(
            context,
            icon: Icons.location_on_outlined,
            title: 'Delivery addresses',
            subtitle: 'Home, office and other saved places',
            onTap: () => showDeliveryAddressSheet(context),
          ),
          const SizedBox(height: 8),
          _tile(
            context,
            icon: Icons.help_outline_rounded,
            title: 'Help & support',
            subtitle: 'FAQs, call us, report issues',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 8),
            _tile(
              context,
              icon: Icons.dns_outlined,
              title: 'Server connection (dev)',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServerSettingsScreen()),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _notificationTile(BuildContext context) {
    final notif = context.watch<NotificationProvider>();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusLg,
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: SwitchListTile(
        value: notif.enabled,
        activeColor: AppTheme.primary,
        onChanged: notif.setEnabled,
        secondary: const Icon(Icons.notifications_active_rounded, color: AppTheme.primary),
        title: Text('Order notifications', style: AppTheme.titleMedium),
        subtitle: Text(
          'Alerts when your cake is baking, ready & delivered',
          style: AppTheme.bodySmall.copyWith(fontSize: 11),
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.surface,
      borderRadius: AppTheme.radiusLg,
      child: InkWell(
        borderRadius: AppTheme.radiusLg,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.titleMedium.copyWith(fontSize: 15)),
                    if (subtitle != null)
                      Text(subtitle, style: AppTheme.bodySmall.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textMuted.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editProfile(
    BuildContext context,
    String name,
    String phone,
  ) async {
    final updated = await showEditProfileSheet(
      context,
      name: name,
      phone: phone,
    );
    if (updated != null && context.mounted) {
      try {
        await context.read<AuthProvider>().updateProfile(
              updated.name,
              updated.phone,
            );
        if (context.mounted) {
          AppSnackBar.success(context, 'Profile updated');
        }
      } catch (_) {
        if (context.mounted) {
          AppSnackBar.error(context, 'Could not update profile');
        }
      }
    }
  }
}
