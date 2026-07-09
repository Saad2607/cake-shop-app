import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/admin_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/edit_profile_sheet.dart';
import '../home/main_screen.dart';
import '../profile/server_settings_screen.dart';

class AdminAccountTab extends StatelessWidget {
  const AdminAccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    final dash = context.watch<AdminProvider>().dashboard;

    return ColoredBox(
      color: AdminTheme.scaffold,
      child: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.headerGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: AppTheme.displayMedium.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (dash != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.receipt_long_rounded,
                        label: 'Total orders',
                        value: '${dash.totalOrders}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.hourglass_top_rounded,
                        label: 'Pending',
                        value: '${dash.pendingOrders}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.people_rounded,
                        label: 'Customers',
                        value: '${dash.customerCount}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.currency_rupee_rounded,
                        label: 'Revenue',
                        value: CurrencyFormatter.format(dash.totalRevenue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              _infoCard(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user.phone.isNotEmpty ? user.phone : 'Not set',
              ),
              const SizedBox(height: 12),
              _infoCard(
                icon: Icons.badge_outlined,
                label: 'Account type',
                value: 'Administrator',
              ),
              const SizedBox(height: 12),
              _infoCard(
                icon: Icons.fingerprint_rounded,
                label: 'User ID',
                value: user.id,
              ),
              const SizedBox(height: 24),
              _adminNotificationCard(context),
              const SizedBox(height: 12),
              if (kDebugMode) ...[
                _actionTile(
                  context,
                  icon: Icons.dns_outlined,
                  title: 'Server connection (dev)',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ServerSettingsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              _actionTile(
                context,
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () => _editProfile(context, user.name, user.phone),
              ),
              const SizedBox(height: 32),
              _signOutButton(context, auth),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
      ),
    );
  }

  Widget _adminNotificationCard(BuildContext context) {
    final notif = context.watch<NotificationProvider>();
    final count = notif.adminNotificationCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: AdminTheme.radiusMd,
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        children: [
          Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            backgroundColor: AdminTheme.warning,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AdminTheme.accent.withValues(alpha: 0.1),
                borderRadius: AdminTheme.radiusSm,
              ),
              child: const Icon(Icons.notifications_active_rounded, color: AdminTheme.accent),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New order alerts', style: AdminTheme.sectionTitle.copyWith(fontSize: 15)),
                Text(
                  count > 0
                      ? '$count new order alert${count == 1 ? '' : 's'} received'
                      : 'Get notified when customers place orders',
                  style: AdminTheme.kpiLabel,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: notif.enabled,
            activeColor: AdminTheme.accent,
            onChanged: (v) => notif.setEnabled(v),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusLg,
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTheme.displayMedium.copyWith(fontSize: 20),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(label, style: AppTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.bodySmall.copyWith(fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: AppTheme.titleMedium.copyWith(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.titleMedium.copyWith(fontSize: 15),
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textMuted.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signOutButton(BuildContext context, AuthProvider auth) {
    const signOutColor = Color(0xFFC62828);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, color: AppTheme.cardBorder),
        const SizedBox(height: 24),
        Text(
          'Account',
          style: AppTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _confirmSignOut(context, auth),
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text('Sign Out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: signOutColor,
            side: BorderSide(color: signOutColor.withValues(alpha: 0.45)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You will need to sign in again to access the admin panel',
          textAlign: TextAlign.center,
          style: AppTheme.bodySmall.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context, AuthProvider auth) async {
    const signOutColor = Color(0xFFC62828);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: AppTheme.radiusLg,
            boxShadow: [AppTheme.softShadow],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: signOutColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: signOutColor, size: 28),
              ),
              const SizedBox(height: 16),
              Text('Sign out?', style: AppTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'You can sign back in anytime with your admin credentials.',
                textAlign: TextAlign.center,
                style: AppTheme.bodySmall.copyWith(height: 1.45),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: signOutColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await auth.logout();
    context.read<CartProvider>().clearSession();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (_) => false,
      );
    }
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
