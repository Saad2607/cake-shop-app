import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/promo_offer_model.dart';
import '../../theme/admin_theme.dart';
import '../../utils/currency_formatter.dart';

class AdminPromoAnalytics extends StatelessWidget {
  final List<PromoOfferModel> promos;

  const AdminPromoAnalytics({super.key, required this.promos});

  @override
  Widget build(BuildContext context) {
    final discountPromos = promos
        .where((p) => p.action == PromoActionType.discount && p.code != null)
        .toList();
    final totalUses = discountPromos.fold<int>(0, (s, p) => s + p.useCount);
    final totalSaved = discountPromos.fold<double>(0, (s, p) => s + p.totalDiscount);
    final withUsage = discountPromos.where((p) => p.useCount > 0).toList()
      ..sort((a, b) => b.useCount.compareTo(a.useCount));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Promo performance', style: AdminTheme.sectionTitle),
        const SizedBox(height: 12),
        Row(
          children: [
            _kpi('$totalUses', 'Redemptions', AdminTheme.info),
            const SizedBox(width: 10),
            _kpi(CurrencyFormatter.format(totalSaved), 'Discount given', AdminTheme.accent),
            const SizedBox(width: 10),
            _kpi(
              '${promos.where((p) => p.active && !p.isExpired).length}',
              'Live on home',
              AdminTheme.online,
            ),
          ],
        ),
        if (withUsage.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
            decoration: AdminTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Redemptions by code', style: AdminTheme.kpiLabel.copyWith(fontSize: 12)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: withUsage.first.useCount * 1.3 + 1,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: AdminTheme.border,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (v, _) => Text(
                              v.toInt().toString(),
                              style: AdminTheme.kpiLabel.copyWith(fontSize: 9),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (i, _) {
                              final idx = i.toInt();
                              if (idx < 0 || idx >= withUsage.length) {
                                return const SizedBox.shrink();
                              }
                              final code = withUsage[idx].code ?? '';
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  code.length > 8 ? '${code.substring(0, 7)}…' : code,
                                  style: AdminTheme.kpiLabel.copyWith(fontSize: 9),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(withUsage.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: withUsage[i].useCount.toDouble(),
                              color: AdminTheme.accent,
                              width: 22,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _kpi(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: AdminTheme.cardDecoration,
        child: Column(
          children: [
            Text(
              value,
              style: AdminTheme.kpiValue.copyWith(color: color, fontSize: 16),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(label, style: AdminTheme.kpiLabel, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class AdminPromoBannerPreview extends StatelessWidget {
  final List<PromoOfferModel> promos;

  const AdminPromoBannerPreview({super.key, required this.promos});

  @override
  Widget build(BuildContext context) {
    final live = promos.where((p) => p.active && !p.isExpired).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (live.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: AdminTheme.cardDecoration,
        child: Row(
          children: [
            Icon(Icons.visibility_off_outlined, color: AdminTheme.textSecondary.withValues(alpha: 0.6)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No active offers on the home screen. Activate an offer or create a new one.',
                style: AdminTheme.kpiLabel.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Home banner preview', style: AdminTheme.sectionTitle),
        const SizedBox(height: 4),
        Text(
          'This is how customers see offers on the home tab',
          style: AdminTheme.kpiLabel,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: live.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final p = live[i];
              return Container(
                width: 280,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: p.gradientColors,
                  ),
                  borderRadius: AdminTheme.radiusMd,
                  boxShadow: [
                    BoxShadow(
                      color: p.gradientColors.first.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(p.iconData, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            p.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
