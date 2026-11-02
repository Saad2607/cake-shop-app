import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/delivery_address_sheet.dart';
import '../../widgets/edit_profile_sheet.dart';
import '../../widgets/glass/glass_card.dart';
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
        title: Text('Settings', style: AppTheme.displayMedium.copyWith(fontSize: 20)),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _notificationTile(context),
          const SizedBox(height: 10),
          _tile(
            context,
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            subtitle: 'Update your name and phone number',
            onTap: () => _editProfile(context, user.name, user.phone),
          ),
          const SizedBox(height: 10),
          _tile(
            context,
            icon: Icons.location_on_outlined,
            title: 'Delivery Addresses',
            subtitle: 'Home, office and other saved locations',
            onTap: () => showDeliveryAddressSheet(context),
          ),
          const SizedBox(height: 10),
          _tile(
            context,
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            subtitle: 'FAQs, call customer care, report issues',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 10),
            _tile(
              context,
              icon: Icons.dns_outlined,
              title: 'Server connection (dev)',
              subtitle: 'Configure local / remote API endpoint',
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

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SwitchListTile(
        value: notif.enabled,
        activeColor: AppTheme.primary,
        onChanged: notif.setEnabled,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.notifications_active_rounded, color: AppTheme.primary, size: 20),
        ),
        title: Text('Order Notifications', style: AppTheme.titleMedium.copyWith(fontSize: 14)),
        subtitle: Text(
          'Alerts when your cake is baking, ready & out for delivery',
          style: AppTheme.bodySmall.copyWith(fontSize: 11, color: AppTheme.textMuted),
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
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.titleMedium.copyWith(fontSize: 14)),
                if (subtitle != null)
                  Text(subtitle, style: AppTheme.bodySmall.copyWith(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted.withValues(alpha: 0.5)),
        ],
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
