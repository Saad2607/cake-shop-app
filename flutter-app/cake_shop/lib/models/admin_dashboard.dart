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
      breakdown[k] = (v as num).toInt();
    });
    return AdminDashboard(
      totalOrders: (json['totalOrders'] as num).toInt(),
      pendingOrders: (json['pendingOrders'] as num).toInt(),
      todayOrders: (json['todayOrders'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      todayRevenue: (json['todayRevenue'] as num).toDouble(),
      customerCount: (json['customerCount'] as num).toInt(),
      cakeCount: (json['cakeCount'] as num).toInt(),
      outOfStockCount: (json['outOfStockCount'] as num).toInt(),
      statusBreakdown: breakdown,
      weeklyStats: (json['weeklyStats'] as List? ?? [])
          .map((e) => WeeklyStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentOrders: (json['recentOrders'] as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
