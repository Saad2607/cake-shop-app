import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../theme/admin_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/empty_state.dart';

class AdminCustomersTab extends StatefulWidget {
  const AdminCustomersTab({super.key});

  @override
  State<AdminCustomersTab> createState() => _AdminCustomersTabState();
}

class _AdminCustomersTabState extends State<AdminCustomersTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final dateFormat = DateFormat('dd MMM yyyy');

    final customers = admin.customers.where((c) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.phone.contains(q);
    }).toList();

    final totalSpent = admin.customers.fold<double>(0, (s, c) => s + c.totalSpent);

    if (admin.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AdminTheme.accent));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: _summaryChip('${admin.customers.length}', 'Customers'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryChip(CurrencyFormatter.format(totalSpent), 'Total spent'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search name, email, phone…',
              prefixIcon: const Icon(Icons.search_rounded, color: AdminTheme.textSecondary),
              filled: true,
              fillColor: AdminTheme.surface,
              border: OutlineInputBorder(
                borderRadius: AdminTheme.radiusMd,
                borderSide: const BorderSide(color: AdminTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AdminTheme.radiusMd,
                borderSide: const BorderSide(color: AdminTheme.border),
              ),
            ),
            onChanged: (v) => setState(() => _query = v.trim()),
          ),
        ),
        Expanded(
          child: customers.isEmpty
              ? EmptyState(
                  icon: Icons.people_outline,
                  title: admin.customers.isEmpty ? 'No customers yet' : 'No matches',
                  subtitle: admin.customers.isEmpty
                      ? 'Registered customers will appear here.'
                      : 'Try a different search.',
                )
              : RefreshIndicator(
                  color: AdminTheme.accent,
                  onRefresh: admin.loadCustomers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: customers.length,
                    itemBuilder: (_, i) {
                      final c = customers[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: AdminTheme.cardDecoration,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AdminTheme.accent.withValues(alpha: 0.1),
                              child: Text(
                                c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: AdminTheme.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.name,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                                  Text(
                                    c.email,
                                    style: const TextStyle(fontSize: 12, color: AdminTheme.textSecondary),
                                  ),
                                  if (c.phone.isNotEmpty)
                                    Text(
                                      c.phone,
                                      style: const TextStyle(fontSize: 12, color: AdminTheme.textSecondary),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${c.orderCount} orders',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                Text(
                                  CurrencyFormatter.format(c.totalSpent),
                                  style: const TextStyle(
                                    color: AdminTheme.accent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                if (c.createdAt > 0)
                                  Text(
                                    'Since ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(c.createdAt))}',
                                    style: AdminTheme.kpiLabel.copyWith(fontSize: 10),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _summaryChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AdminTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AdminTheme.kpiValue.copyWith(fontSize: 18)),
          Text(label, style: AdminTheme.kpiLabel),
        ],
      ),
    );
  }
}
