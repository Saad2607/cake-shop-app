import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/delivery_address_sheet.dart';
import '../../widgets/edit_profile_sheet.dart';
import '../profile/help_support_screen.dart';
import '../profile/wishlist_screen.dart';
import '../profile/server_settings_screen.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../home/main_screen.dart';

class ProfileTab extends StatelessWidget {
  final ValueChanged<int>? onSwitchTab;

  const ProfileTab({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: AppTheme.headerGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.person_outline, size: 64, color: Colors.white),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Your Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sign in to place orders, track deliveries, and manage your profile.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text('Create Account'),
                  ),
                ),
                const Spacer(),
                if (kDebugMode)
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ServerSettingsScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.dns_outlined, size: 18),
                    label: const Text('Server connection (dev)'),
                  ),
                if (kDebugMode) const SizedBox(height: 8),
                Text(
                  'You can browse cakes without signing in',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
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
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
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
                _statsRow(context),
                const SizedBox(height: 16),
                _notificationCard(context),
                const SizedBox(height: 20),
                Text(
                  'Your orders',
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 10),
                _actionTile(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'Order history',
                  subtitle: 'Track active & past deliveries',
                  onTap: () => onSwitchTab?.call(2),
                ),
                const SizedBox(height: 8),
                _actionTile(
                  context,
                  icon: Icons.favorite_border_rounded,
                  title: 'My wishlist',
                  subtitle: 'Saved cakes you love',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Account & help',
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 10),
                _actionTile(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'Delivery address',
                  subtitle: 'Change where we deliver',
                  onTap: () => showDeliveryAddressSheet(context),
                ),
                const SizedBox(height: 8),
                _actionTile(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'Help & support',
                  subtitle: 'FAQs, call us, report issues',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                  ),
                ),
                const SizedBox(height: 8),
                _actionTile(
                  context,
                  icon: Icons.edit_outlined,
                  title: 'Edit profile',
                  onTap: () => _editProfile(context, user.name, user.phone),
                ),
                const SizedBox(height: 12),
                _infoCard(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: user.phone.isNotEmpty ? user.phone : 'Not set',
                ),
                const SizedBox(height: 32),
                _signOutButton(context, auth),
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ServerSettingsScreen()),
                      ),
                      icon: const Icon(Icons.settings_outlined, size: 16),
                      label: const Text('Server settings (dev)'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textMuted,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;
    final active = orders.where((o) => o.status != 'DELIVERED' && o.status != 'CANCELLED').length;

    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.receipt_long_rounded,
            label: 'Total orders',
            value: '${orders.length}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.local_shipping_rounded,
            label: 'Active',
            value: '$active',
          ),
        ),
      ],
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
          Text(value, style: AppTheme.displayMedium.copyWith(fontSize: 22)),
          Text(label, style: AppTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _notificationCard(BuildContext context) {
    final notif = context.watch<NotificationProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusLg,
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_active_rounded, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order notifications', style: AppTheme.titleMedium),
                Text(
                  'Get alerts when your cake is baking, ready & delivered',
                  style: AppTheme.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: notif.enabled,
            activeColor: AppTheme.primary,
            onChanged: (v) => notif.setEnabled(v),
          ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ],
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
          'You will need to sign in again to place orders',
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
                child: const Icon(
                  Icons.logout_rounded,
                  color: signOutColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text('Sign out?', style: AppTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'You can sign back in anytime to view orders and checkout.',
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
    context.read<CartProvider>().clearGuestCart();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (_) => false,
      );
    }
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.titleMedium.copyWith(fontSize: 15),
                    ),
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
