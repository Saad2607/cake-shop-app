import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/promo_offer_model.dart';
import '../../providers/admin_provider.dart';
import '../../theme/admin_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/promo_countdown.dart';
import '../../widgets/admin/admin_promo_analytics.dart';
import '../../widgets/empty_state.dart';
import 'admin_promo_form_screen.dart';

class AdminPromosTab extends StatefulWidget {
  const AdminPromosTab({super.key});

  @override
  State<AdminPromosTab> createState() => _AdminPromosTabState();
}

class _AdminPromosTabState extends State<AdminPromosTab> {
  String _filter = 'ALL';

  static const _filters = [
    ('ALL', 'All'),
    ('ACTIVE', 'Active'),
    ('DISCOUNT', 'Discount'),
    ('INFO', 'Info'),
    ('BROWSE', 'Browse'),
    ('INACTIVE', 'Inactive'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPromos();
    });
  }

  List<PromoOfferModel> _filtered(List<PromoOfferModel> promos) {
    switch (_filter) {
      case 'ACTIVE':
        return promos.where((p) => p.active && !p.isExpired).toList();
      case 'DISCOUNT':
        return promos.where((p) => p.action == PromoActionType.discount).toList();
      case 'INFO':
        return promos.where((p) => p.action == PromoActionType.info).toList();
      case 'BROWSE':
        return promos.where((p) => p.action == PromoActionType.browseCategory).toList();
      case 'INACTIVE':
        return promos.where((p) => !p.active || p.isExpired).toList();
      default:
        return promos;
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final filtered = _filtered(admin.promos);

    return Scaffold(
      backgroundColor: AdminTheme.scaffold,
      body: admin.promosLoading && admin.promos.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AdminTheme.accent))
          : admin.error != null && admin.promos.isEmpty
              ? EmptyState(
                  icon: Icons.error_outline,
                  title: 'Failed to load offers',
                  subtitle: admin.error!,
                  actionLabel: 'Retry',
                  onAction: admin.loadPromos,
                )
              : RefreshIndicator(
                  color: AdminTheme.accent,
                  onRefresh: admin.loadPromos,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                    children: [
                      AdminPromoAnalytics(promos: admin.promos),
                      const SizedBox(height: 24),
                      AdminPromoBannerPreview(promos: admin.promos),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Manage offers', style: AdminTheme.sectionTitle),
                          Text(
                            '${filtered.length} shown',
                            style: AdminTheme.kpiLabel,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final (key, label) = _filters[i];
                            final selected = _filter == key;
                            return FilterChip(
                              label: Text(label, style: const TextStyle(fontSize: 12)),
                              selected: selected,
                              showCheckmark: false,
                              selectedColor: AdminTheme.accent,
                              backgroundColor: AdminTheme.surface,
                              side: BorderSide(
                                color: selected ? AdminTheme.accent : AdminTheme.border,
                              ),
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : AdminTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (_) => setState(() => _filter = key),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: EmptyState(
                            icon: Icons.local_offer_outlined,
                            title: _filter == 'ALL' ? 'No offers yet' : 'No matching offers',
                            subtitle: _filter == 'ALL'
                                ? 'Create promos that appear on the customer home screen.'
                                : 'Try another filter or add a new offer.',
                            actionLabel: 'Add offer',
                            onAction: () => _openForm(context),
                          ),
                        )
                      else
                        ...filtered.map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _PromoCard(
                              promo: p,
                              onEdit: () => _openForm(context, promo: p),
                              onDelete: () => _confirmDelete(context, p),
                              onToggle: () => admin.updatePromo(
                                p.id,
                                {'active': !p.active},
                              ),
                              onDuplicate: () => _openForm(context, duplicateFrom: p),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: AdminTheme.accent,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add offer'),
      ),
    );
  }

  void _openForm(
    BuildContext context, {
    PromoOfferModel? promo,
    PromoOfferModel? duplicateFrom,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminPromoFormScreen(
          promo: promo,
          duplicateFrom: duplicateFrom,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, PromoOfferModel promo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete offer?'),
        content: Text('Remove "${promo.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AdminProvider>().deletePromo(promo.id);
    }
  }
}

class _PromoCard extends StatelessWidget {
  final PromoOfferModel promo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onDuplicate;

  const _PromoCard({
    required this.promo,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final expired = promo.isExpired;
    final statusColor = !promo.active
        ? AdminTheme.textSecondary
        : expired
            ? const Color(0xFFDC2626)
            : AdminTheme.online;

    return Container(
      decoration: AdminTheme.cardDecoration,
      child: InkWell(
        onTap: onEdit,
        borderRadius: AdminTheme.radiusMd,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: promo.gradientColors),
                  borderRadius: AdminTheme.radiusSm,
                ),
                child: Icon(promo.iconData, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promo.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      promo.subtitle,
                      style: AdminTheme.kpiLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (promo.action == PromoActionType.discount && promo.code != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _metric(Icons.redeem_rounded, '${promo.useCount} uses'),
                          const SizedBox(width: 12),
                          _metric(
                            Icons.savings_outlined,
                            CurrencyFormatter.format(promo.totalDiscount),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _chip(_actionLabel(promo.action)),
                        if (promo.code != null) _chip(promo.code!),
                        _chip(
                          !promo.active
                              ? 'Inactive'
                              : expired
                                  ? 'Expired'
                                  : 'Active',
                          color: statusColor,
                        ),
                        if (promo.expiresAtDate != null)
                          _chip(PromoCountdown.label(promo.expiresAtDate!)),
                        if (promo.active && !expired)
                          _chip('On home', color: AdminTheme.online),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'edit':
                      onEdit();
                    case 'duplicate':
                      onDuplicate();
                    case 'toggle':
                      onToggle();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(promo.active ? 'Deactivate' : 'Activate'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AdminTheme.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: AdminTheme.kpiLabel.copyWith(color: AdminTheme.textPrimary)),
      ],
    );
  }

  String _actionLabel(PromoActionType action) {
    switch (action) {
      case PromoActionType.discount:
        return 'Discount';
      case PromoActionType.browseCategory:
        return 'Browse';
      case PromoActionType.info:
        return 'Info';
    }
  }

  Widget _chip(String label, {Color? color}) {
    final c = color ?? AdminTheme.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c),
      ),
    );
  }
}
