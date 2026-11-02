import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_branding.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/promo_catalog_provider.dart';
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
import '../../widgets/glass/glass_search_bar.dart';
import '../../widgets/promo_banner.dart';
import '../../widgets/product_carousel_tile.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sort_filter_sheet.dart';
import '../../widgets/app_logo.dart';
import '../catalog/cake_customizer_screen.dart';
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
  final _scrollController = ScrollController();
  Timer? _searchDebounce;
  bool _gridEntranceDone = false;

  static const _categories = [
    _Cat('ALL', 'All Cakes', Icons.auto_awesome_rounded),
    _Cat('BIRTHDAY', 'Birthday', Icons.celebration_rounded),
    _Cat('WEDDING', 'Wedding', Icons.favorite_rounded),
    _Cat('CUPCAKE', 'Cupcakes', Icons.cake_rounded),
    _Cat('CUSTOM', 'Custom', Icons.brush_rounded),
    _Cat('SEASONAL', 'Seasonal', Icons.ac_unit_rounded),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<CakeProvider>().loadCakes(),
        context.read<PromoCatalogProvider>().loadActivePromos(),
      ]);
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) setState(() => _gridEntranceDone = true);
      });
    });
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (!_gridEntranceDone && mounted) {
      setState(() => _gridEntranceDone = true);
    }
    final auth = context.read<AuthProvider>();
    await Future.wait([
      context.read<CakeProvider>().loadCakes(),
      context.read<PromoCatalogProvider>().loadActivePromos(),
      if (auth.isLoggedIn) context.read<OrderProvider>().loadOrders(),
    ]);
  }

  void _onSearchChanged(String value, CakeProvider provider) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 320), () {
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
        builder: (ctx) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none_rounded, color: AppTheme.primary, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text('Order updates', style: AppTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to track your deliveries and get real-time order alerts.',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
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
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.55,
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.textMuted.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Active Deliveries', style: AppTheme.titleLarge),
                const SizedBox(height: 12),
                if (active.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No active orders right now. Treat yourself to fresh cake!',
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: active.length.clamp(0, 3),
                      separatorBuilder: (_, __) => const Divider(height: 18, color: AppTheme.cardBorder),
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
                            borderRadius: BorderRadius.circular(14),
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
                                          style: AppTheme.bodySmall.copyWith(color: color, fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: AppTheme.primary,
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
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.ctaGradient,
                    borderRadius: AppTheme.radiusMd,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.onSwitchTab?.call(4); // profile or orders
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('View all orders'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CakeProvider>();
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.primary,
        backgroundColor: Colors.white,
        displacement: 28,
        edgeOffset: topPadding,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: _cakeStudioBanner(context),
            ),
          ),
          if (provider.bestsellers.length >= 3)
            SliverToBoxAdapter(child: _bestsellersRow(provider)),
          SliverToBoxAdapter(child: _orderAgainSection(context)),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: provider.selectedCategory == 'ALL'
                  ? 'Artisan Creations'
                  : _categories
                      .firstWhere((c) => c.key == provider.selectedCategory)
                      .label,
              subtitle: provider.displayCakes.isNotEmpty &&
                      !provider.isInitialLoading
                  ? '${provider.displayCakes.length} handcrafted delights · baked fresh today'
                  : null,
            ),
          ),
          if (provider.isInitialLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppTheme.primary,
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
                subtitle:
                    'Try another keyword or browse another delightful category.',
                actionLabel:
                    provider.searchQuery.isNotEmpty ? 'Clear search' : null,
                onAction: provider.searchQuery.isNotEmpty
                    ? () {
                        _searchController.clear();
                        provider.setSearch('');
                      }
                    : null,
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
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
                    final card = CakeCardWidget(
                      key: ValueKey(cake.id),
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
                    );
                    if (_gridEntranceDone) return card;
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 350 + (i % 4) * 80),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 18 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: card,
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
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final greeting = user != null && user.name.isNotEmpty
        ? 'Hi, ${user.name.split(' ').first}'
        : 'Welcome';

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
                              Row(
                                children: [
                                  Text(
                                    greeting,
                                    style: AppTheme.titleMedium.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('✨', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                              Text(
                                kAppName,
                                style: AppTheme.displayLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 27,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Liquid Glass Notification Action
                        GestureDetector(
                          onTap: () => _showOrderUpdates(context),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.28),
                                  ),
                                ),
                                child: Badge(
                                  isLabelVisible: context
                                          .watch<NotificationProvider>()
                                          .customerNotificationCount >
                                      0,
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DeliveryEtaChip(
                      label: DeliveryEta.homeChipLabel(),
                      light: true,
                    ),
                    const SizedBox(height: 12),
                    // Liquid Glass Delivery Location Card
                    GestureDetector(
                      onTap: () => showDeliveryAddressSheet(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.gold,
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
                                        'DELIVER TO',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.72),
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.6,
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
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Floating Search Bar with Liquid Glass styling
        Transform.translate(
          offset: const Offset(0, -20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GlassSearchBar(
              controller: _searchController,
              onChanged: (v) => _onSearchChanged(v, provider),
              onSubmitted: provider.setSearch,
              onClear: () => provider.setSearch(''),
              onFilterTap: () => showSortFilterSheet(context, provider),
              hasActiveFilter: provider.sortOption != CakeSortOption.recommended,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Categories horizontal list
        SizedBox(
          height: 98,
          child: Stack(
            children: [
              ListView.separated(
                primary: false,
                physics: const BouncingScrollPhysics(),
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
                width: 28,
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
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _bestsellersRow(CakeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Top Bestsellers',
          subtitle: 'Most loved handcrafted creations',
          actionLabel: 'See all',
          onAction: () => widget.onSwitchTab?.call(1),
        ),
        SizedBox(
          height: 196,
          child: ListView.separated(
            primary: false,
            physics: const BouncingScrollPhysics(),
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
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusLg,
          border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 1.2),
          boxShadow: [AppTheme.softShadow],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppTheme.radiusLg,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
            ),
            borderRadius: AppTheme.radiusLg,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.replay_rounded, color: AppTheme.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reorder your favourite', style: AppTheme.titleMedium),
                        Text(
                          order.items?.first.cakeName ?? order.orderNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textMuted, size: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cakeStudioBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CakeCustomizerScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2B1D19), Color(0xFF4A252D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2B1D19).withValues(alpha: 0.2),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                  width: 1.2,
                ),
              ),
              child: const Center(
                child: Text('🎨', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Cake Studio 3D',
                        style: AppTheme.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.gold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'STUDIO',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Customize base shape, toppings & photo print in 3D',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
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
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: 86,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryLight.withValues(alpha: 0.55)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.primary.withValues(alpha: 0.5)
                : AppTheme.cardBorder,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [AppTheme.softShadow],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: selected
                    ? AppTheme.ctaGradient
                    : LinearGradient(
                        colors: [
                          AppTheme.primaryLight.withValues(alpha: 0.35),
                          AppTheme.creamDark.withValues(alpha: 0.6),
                        ],
                      ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.labelBold.copyWith(
                  fontSize: 10,
                  color: selected ? AppTheme.primary : AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
