import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_branding.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cake_provider.dart';
import '../../providers/delivery_address_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/delivery_eta.dart';
import '../../utils/order_status.dart';
import '../../widgets/cake_card_widget.dart';
import '../../widgets/delivery_address_sheet.dart';
import '../../widgets/delivery_eta_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/promo_banner.dart';
import '../../widgets/product_carousel_tile.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sort_filter_sheet.dart';
import '../../widgets/app_logo.dart';
import '../catalog/cake_detail_screen.dart';
import '../orders/order_detail_screen.dart';

class HomeTab extends StatefulWidget {
  final ValueChanged<int>? onSwitchTab;

  const HomeTab({super.key, this.onSwitchTab});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  static const _categories = [
    _Cat('ALL', 'All', Icons.grid_view_rounded),
    _Cat('BIRTHDAY', 'Birthday', Icons.celebration_rounded),
    _Cat('WEDDING', 'Wedding', Icons.favorite_rounded),
    _Cat('CUPCAKE', 'Cupcake', Icons.cake_outlined),
    _Cat('CUSTOM', 'Custom', Icons.brush_rounded),
    _Cat('SEASONAL', 'Seasonal', Icons.ac_unit_rounded),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CakeProvider>().loadCakes();
    });
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value, CakeProvider provider) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      provider.setSearch(value.trim());
    });
  }

  void _showOrderUpdates(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final notif = context.read<NotificationProvider>();
    if (auth.isLoggedIn) {
      notif.clearCustomerCount();
      await context.read<OrderProvider>().loadOrders();
      if (!context.mounted) return;
    }
    if (!auth.isLoggedIn) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_none_rounded, color: AppTheme.primary, size: 40),
              const SizedBox(height: 12),
              Text('Order updates', style: AppTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Sign in to track your deliveries and get status updates.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      );
      return;
    }

    final orders = context.read<OrderProvider>().orders;
    final active = orders.where((o) => o.status != 'DELIVERED' && o.status != 'CANCELLED').toList();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.5,
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Order updates', style: AppTheme.titleLarge),
            const SizedBox(height: 12),
            if (active.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No active orders right now.',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: active.length.clamp(0, 3),
                  separatorBuilder: (_, __) => const Divider(height: 20, color: AppTheme.cardBorder),
                  itemBuilder: (_, i) {
                    final order = active[i];
                    final color = AppTheme.orderStatusColor(order.status);
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailScreen(order: order),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(order.orderNumber, style: AppTheme.titleMedium),
                                    const SizedBox(height: 2),
                                    Text(
                                      OrderStatusFlow.label(order.status),
                                      style: AppTheme.bodySmall.copyWith(color: color),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: AppTheme.primary.withValues(alpha: 0.7),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                widget.onSwitchTab?.call(2);
              },
              child: const Text('View all orders'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CakeProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: provider.loadCakes,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(provider)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: PromoBanner(
                  onBrowseCategory: provider.setCategory,
                ),
              ),
            ),
            if (provider.bestsellers.length >= 3)
              SliverToBoxAdapter(child: _bestsellersRow(provider)),
            SliverToBoxAdapter(child: _orderAgainSection(context)),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: provider.selectedCategory == 'ALL'
                    ? 'Handcrafted for you'
                    : _categories
                        .firstWhere((c) => c.key == provider.selectedCategory)
                        .label,
                subtitle: provider.displayCakes.isNotEmpty && !provider.isLoading
                    ? '${provider.displayCakes.length} artisan creations · baked fresh daily'
                    : provider.isLoading && provider.cakes.isNotEmpty
                        ? 'Refreshing…'
                        : null,
              ),
            ),
            if (provider.isLoading && provider.cakes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppTheme.primary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Curating sweet delights…',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
            else if (provider.error != null && provider.cakes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: 'Connection issue',
                  subtitle: provider.error!,
                  actionLabel: 'Try again',
                  onAction: provider.loadCakes,
                ),
              )
            else if (provider.displayCakes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No cakes found',
                  subtitle: 'Try a different search or browse another category.',
                  actionLabel: provider.searchQuery.isNotEmpty ? 'Clear search' : null,
                  onAction: provider.searchQuery.isNotEmpty
                      ? () {
                          _searchController.clear();
                          provider.setSearch('');
                        }
                      : null,
                ),
              )
            else ...[
              if (provider.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      color: AppTheme.primary,
                      backgroundColor: AppTheme.cardBorder,
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.58,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final cake = provider.displayCakes[i];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 350 + (i % 4) * 80),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        ),
                        child: CakeCardWidget(
                          cake: cake,
                          onTap: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  CakeDetailScreen(cakeId: cake.id),
                              transitionsBuilder: (_, anim, __, child) =>
                                  FadeTransition(opacity: anim, child: child),
                              transitionDuration:
                                  const Duration(milliseconds: 280),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: provider.displayCakes.length,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CakeProvider provider) {
    final delivery = context.watch<DeliveryAddressProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipPath(
          clipper: _HeaderCurveClipper(),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AppLogo.header(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kAppName,
                                style: AppTheme.displayLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 28,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Artisan cakes & confections',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showOrderUpdates(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Badge(
                              isLabelVisible: context.watch<NotificationProvider>().customerNotificationCount > 0,
                              label: Text(
                                '${context.watch<NotificationProvider>().customerNotificationCount}',
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: AppTheme.gold,
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DeliveryEtaChip(
                      label: DeliveryEta.homeChipLabel(),
                      light: true,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => showDeliveryAddressSheet(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.gold.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Deliver to',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    delivery.displayLine,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    delivery.hasAddress ? '2–4 hrs' : 'Set',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: AppTheme.radiusMd,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryDark.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTheme.bodyMedium.copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search cakes, flavors, occasions…',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppTheme.primary.withValues(alpha: 0.7),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.setSearch('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: AppTheme.radiusMd,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (v) => _onSearchChanged(v, provider),
                      onSubmitted: provider.setSearch,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: AppTheme.surface,
                  borderRadius: AppTheme.radiusMd,
                  elevation: 0,
                  shadowColor: AppTheme.primaryDark.withValues(alpha: 0.12),
                  child: InkWell(
                    onTap: () => showSortFilterSheet(context, provider),
                    borderRadius: AppTheme.radiusMd,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: AppTheme.radiusMd,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryDark.withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.tune_rounded, color: AppTheme.primary, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 102,
          child: Stack(
            children: [
              ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 24, 0),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final selected = provider.selectedCategory == cat.key;
                  return _CategoryTile(
                    icon: cat.icon,
                    label: cat.label,
                    selected: selected,
                    onTap: () => provider.setCategory(cat.key),
                  );
                },
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 32,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppTheme.background.withValues(alpha: 0),
                          AppTheme.background,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _bestsellersRow(CakeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Bestsellers',
          subtitle: 'Top rated by our customers',
        ),
        SizedBox(
          height: 188,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            itemCount: provider.bestsellers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final cake = provider.bestsellers[i];
              return ProductCarouselTile(
                cake: cake,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CakeDetailScreen(cakeId: cake.id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _orderAgainSection(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) return const SizedBox.shrink();

    final orders = context.watch<OrderProvider>().orders;
    final last = orders.where((o) => o.status == 'DELIVERED').toList();
    if (last.isEmpty) return const SizedBox.shrink();
    final order = last.first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Material(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusLg,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
          ),
          borderRadius: AppTheme.radiusLg,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: AppTheme.radiusLg,
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.goldLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.replay_rounded, color: AppTheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order again', style: AppTheme.titleMedium),
                      Text(
                        order.items?.first.cakeName ?? order.orderNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 36)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height + 12,
        size.width,
        size.height - 36,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _Cat {
  final String key;
  final String label;
  final IconData icon;

  const _Cat(this.key, this.label, this.icon);
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 88,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withValues(alpha: 0.08) : AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.cardBorder,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [AppTheme.softShadow],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: selected
                    ? AppTheme.ctaGradient
                    : LinearGradient(
                        colors: [
                          AppTheme.primaryLight.withValues(alpha: 0.3),
                          AppTheme.goldLight.withValues(alpha: 0.5),
                        ],
                      ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : AppTheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.labelBold.copyWith(
                  fontSize: 10,
                  color: selected ? AppTheme.primary : AppTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
