import '../models/order.dart';
import '../models/promo_offer_model.dart';

class AdminDashboard {
  final int totalOrders;
  final int pendingOrders;
  final int todayOrders;
  final double totalRevenue;
  final double todayRevenue;
  final int customerCount;
  final int cakeCount;
  final int outOfStockCount;
  final Map<String, int> statusBreakdown;
  final List<WeeklyStat> weeklyStats;
  final List<Order> recentOrders;

  AdminDashboard({
    required this.totalOrders,
    required this.pendingOrders,
    required this.todayOrders,
    required this.totalRevenue,
    required this.todayRevenue,
    required this.customerCount,
    required this.cakeCount,
    required this.outOfStockCount,
    required this.statusBreakdown,
    required this.weeklyStats,
    required this.recentOrders,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    final breakdown = <String, int>{};
    (json['statusBreakdown'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
      if (v is num) breakdown[k] = v.toInt();
    });

    final weeklyList = (json['weeklyStats'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => WeeklyStat.fromJson(e))
        .toList();

    final orderList = (json['recentOrders'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => Order.fromJson(e))
        .toList();

    return AdminDashboard(
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      pendingOrders: (json['pendingOrders'] as num?)?.toInt() ?? 0,
      todayOrders: (json['todayOrders'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0.0,
      customerCount: (json['customerCount'] as num?)?.toInt() ?? 0,
      cakeCount: (json['cakeCount'] as num?)?.toInt() ?? 0,
      outOfStockCount: (json['outOfStockCount'] as num?)?.toInt() ?? 0,
      statusBreakdown: breakdown,
      weeklyStats: weeklyList,
      recentOrders: orderList,
    );
  }
}
