import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/admin_dashboard.dart';
import '../../models/promo_offer_model.dart';
import '../../theme/admin_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/order_status.dart';

class AdminDashboardCharts extends StatelessWidget {
  final AdminDashboard dash;

  const AdminDashboardCharts({super.key, required this.dash});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Last 7 days', style: AdminTheme.sectionTitle),
        const SizedBox(height: 12),
        _WeeklyChart(stats: dash.weeklyStats),
        const SizedBox(height: 24),
        Text('Orders by status', style: AdminTheme.sectionTitle),
        const SizedBox(height: 12),
        _StatusPieChart(breakdown: dash.statusBreakdown),
      ],
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<WeeklyStat> stats;

  const _WeeklyChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: AdminTheme.cardDecoration,
        child: Text('No data yet', style: AdminTheme.kpiLabel),
      );
    }

    final maxRevenue = stats.map((s) => s.revenue).fold(0.0, (a, b) => a > b ? a : b);
    final revenueMax = maxRevenue > 0 ? maxRevenue * 1.2 : 1000.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
      decoration: AdminTheme.cardDecoration,
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: revenueMax,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: revenueMax / 4,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AdminTheme.border,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      interval: revenueMax / 4,
                      getTitlesWidget: (v, _) => Text(
                        v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : v.toInt().toString(),
                        style: AdminTheme.kpiLabel.copyWith(fontSize: 9),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (i, _) {
                        final idx = i.toInt();
                        if (idx < 0 || idx >= stats.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            stats[idx].label,
                            style: AdminTheme.kpiLabel.copyWith(fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      stats.length,
                      (i) => FlSpot(i.toDouble(), stats[i].revenue),
                    ),
                    isCurved: true,
                    color: AdminTheme.accent,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 4,
                        color: AdminTheme.accent,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AdminTheme.accent.withValues(alpha: 0.08),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) {
                      final idx = s.x.toInt();
                      final orders = idx >= 0 && idx < stats.length ? stats[idx].orders : 0;
                      return LineTooltipItem(
                        '${CurrencyFormatter.format(s.y)}\n$orders orders',
                        const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AdminTheme.accent),
              const SizedBox(width: 6),
              Text('Revenue', style: AdminTheme.kpiLabel),
              const SizedBox(width: 16),
              Text(
                'Peak: ${stats.map((s) => s.orders).reduce((a, b) => a > b ? a : b)} orders/day',
                style: AdminTheme.kpiLabel.copyWith(color: AdminTheme.info),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _StatusPieChart extends StatelessWidget {
  final Map<String, int> breakdown;

  const _StatusPieChart({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final entries = breakdown.entries.where((e) => e.value > 0).toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    if (total == 0) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: AdminTheme.cardDecoration,
        child: Text('No orders yet', style: AdminTheme.kpiLabel),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AdminTheme.cardDecoration,
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: entries.map((e) {
                  final color = AdminTheme.statusColor(e.key);
                  return PieChartSectionData(
                    value: e.value.toDouble(),
                    color: color,
                    radius: 42,
                    title: '${((e.value / total) * 100).round()}%',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries.map((e) {
                final color = AdminTheme.statusColor(e.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          OrderStatusFlow.label(e.key),
                          style: AdminTheme.kpiLabel.copyWith(color: AdminTheme.textPrimary),
                        ),
                      ),
                      Text(
                        '${e.value}',
                        style: AdminTheme.kpiLabel.copyWith(
                          color: AdminTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
