import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/primary_button.dart';
import '../profile/account_settings_screen.dart';
import '../profile/celebrations_calendar_screen.dart';
import '../profile/server_settings_screen.dart';
import '../profile/wishlist_screen.dart';
import '../orders/orders_tab.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const Spacer(),
                const AppLogo.home(),
                const SizedBox(height: 24),
                Text(
                  'Your Account',
                  style: AppTheme.displayLarge.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to place orders, track live deliveries, save favorites and manage your profile.',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Sign In',
                  icon: Icons.login_rounded,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
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
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: AppTheme.primary, width: 1.5),
                      foregroundColor: AppTheme.primary,
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
                    icon: const Icon(Icons.dns_outlined, size: 16),
                    label: const Text('Server connection (dev)'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textMuted,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                if (kDebugMode) const SizedBox(height: 4),
                Text(
                  'You can browse cakes freely without signing in',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textMuted.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
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
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.headerGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 34,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user.name,
                        style: AppTheme.displayMedium.copyWith(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.email,
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _statsRow(context),
                const SizedBox(height: 20),
                Text(
                  'YOUR ORDERS & FAVORITES',
                  style: AppTheme.labelBold.copyWith(
                    fontSize: 10,
                    color: AppTheme.primary,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 10),
                _actionTile(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'Order History',
                  subtitle: 'Track active & past cake deliveries',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrdersTab(showBack: true),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _actionTile(
                  context,
                  icon: Icons.favorite_border_rounded,
                  title: 'My Wishlist',
                  subtitle: 'Saved cakes you adore',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                  ),
                ),
                const SizedBox(height: 8),
                _actionTile(
                  context,
                  icon: Icons.celebration_outlined,
                  title: 'Celebrations Calendar',
                  subtitle: 'Birthdays & anniversaries with cake alerts',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CelebrationsCalendarScreen()),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'ACCOUNT & PREFERENCES',
                  style: AppTheme.labelBold.copyWith(
                    fontSize: 10,
                    color: AppTheme.primary,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 10),
                _actionTile(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'Notifications, profile, addresses & help',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
                  ),
                ),
                const SizedBox(height: 8),
                _darkModeTile(context),
                const SizedBox(height: 8),
                _infoCard(
                  icon: Icons.phone_outlined,
                  label: 'Phone number',
                  value: user.phone.isNotEmpty ? user.phone : 'Not set',
                ),
                const SizedBox(height: 28),
                _signOutButton(context, auth),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _darkModeTile(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFFC59F5A).withValues(alpha: 0.2)
                  : AppTheme.primaryLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDark ? const Color(0xFFE6B980) : AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Midnight Chocolatier',
                  style: AppTheme.titleMedium.copyWith(fontSize: 14),
                ),
                Text(
                  isDark ? 'Dark luxury espresso mode' : 'Warm ivory day mode',
                  style: AppTheme.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isDark,
            activeColor: AppTheme.primary,
            onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
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
            label: 'Total Orders',
            value: '${orders.length}',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OrdersTab(showBack: true),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.local_shipping_rounded,
            label: 'Active Delivery',
            value: '$active',
            isHighlight: active > 0,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OrdersTab(showBack: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlight = false,
    VoidCallback? onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      color: isHighlight
          ? AppTheme.primaryLight.withValues(alpha: 0.35)
          : Colors.white.withValues(alpha: 0.65),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighlight
                  ? AppTheme.primary.withValues(alpha: 0.15)
                  : AppTheme.primaryLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTheme.displayMedium.copyWith(
              fontSize: 22,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              fontSize: 11,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
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
    return GlassCard(
      padding: const EdgeInsets.all(14),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(fontSize: 11, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.titleMedium.copyWith(fontSize: 14),
              ),
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
        OutlinedButton.icon(
          onPressed: () => _confirmSignOut(context, auth),
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Sign Out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: signOutColor,
            side: BorderSide(color: signOutColor.withValues(alpha: 0.45)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You will need to sign in again to place orders and view saved addresses',
          textAlign: TextAlign.center,
          style: AppTheme.bodySmall.copyWith(
            fontSize: 11,
            color: AppTheme.textMuted.withValues(alpha: 0.8),
          ),
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: GlassCard(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: signOutColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: signOutColor,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text('Sign Out?', style: AppTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'You can sign back in anytime to view your past orders and continue checkout.',
                textAlign: TextAlign.center,
                style: AppTheme.bodySmall.copyWith(height: 1.45),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
                Text(
                  title,
                  style: AppTheme.titleMedium.copyWith(fontSize: 14),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(fontSize: 11, color: AppTheme.textMuted),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textMuted.withValues(alpha: 0.6),
            size: 20,
          ),
        ],
      ),
    );
  }
}
