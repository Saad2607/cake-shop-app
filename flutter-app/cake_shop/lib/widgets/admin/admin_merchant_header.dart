import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_branding.dart';
import '../../theme/admin_theme.dart';

/// Partner-style liquid glass top bar for merchants.
class AdminMerchantHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? todayOrders;
  final VoidCallback? onRefresh;

  const AdminMerchantHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.todayOrders,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE, d MMM').format(DateTime.now());

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.7),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AdminTheme.accent.withValues(alpha: 0.15),
                          AdminTheme.accent.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: AdminTheme.radiusSm,
                      border: Border.all(
                        color: AdminTheme.accent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: AdminTheme.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                kAppName,
                                style: AdminTheme.sectionTitle.copyWith(fontSize: 17),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AdminTheme.online.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AdminTheme.online.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AdminTheme.online,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Online',
                                    style: AdminTheme.kpiLabel.copyWith(
                                      color: AdminTheme.online,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: AdminTheme.kpiLabel.copyWith(
                            color: AdminTheme.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle ??
                              '$dateLabel${todayOrders != null ? ' · $todayOrders orders today' : ''}',
                          style: AdminTheme.kpiLabel.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  if (onRefresh != null)
                    IconButton(
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh_rounded, size: 22),
                      color: AdminTheme.textSecondary,
                      tooltip: 'Refresh',
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
