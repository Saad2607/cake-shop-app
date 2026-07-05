class AdminCustomer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int createdAt;
  final int orderCount;
  final double totalSpent;

  AdminCustomer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.orderCount,
    required this.totalSpent,
  });

  factory AdminCustomer.fromJson(Map<String, dynamic> json) {
    return AdminCustomer(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      createdAt: json['createdAt'] as int? ?? 0,
      orderCount: json['orderCount'] as int? ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0,
    );
  }
}
