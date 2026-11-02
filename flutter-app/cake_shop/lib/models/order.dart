class Order {
  final String id;
  final String orderNumber;
  final String userId;
  final double totalAmount;
  final double subtotalAmount;
  final double discountAmount;
  final String? promoCode;
  final String status;
  final String deliveryAddress;
  final int deliveryDate;
  final String paymentMethod;
  final int createdAt;
  final List<OrderItem>? items;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final int? rating;
  final String? reviewComment;
  final String? deliveryPartnerId;
  final String? deliveryPartnerName;
  final String? deliveryPartnerPhone;
  final String? deliveryOtp;

  Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.totalAmount,
    double? subtotalAmount,
    this.discountAmount = 0,
    this.promoCode,
    required this.status,
    required this.deliveryAddress,
    required this.deliveryDate,
    required this.paymentMethod,
    required this.createdAt,
    this.items,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.rating,
    this.reviewComment,
    this.deliveryPartnerId,
    this.deliveryPartnerName,
    this.deliveryPartnerPhone,
    this.deliveryOtp,
  }) : subtotalAmount = subtotalAmount ?? totalAmount;

  factory Order.fromJson(Map<String, dynamic> json) {
    String parsedUserId = '';
    final rawUserId = json['userId'];
    if (rawUserId is Map) {
      parsedUserId = (rawUserId['id'] ?? rawUserId['_id'])?.toString() ?? '';
    } else if (rawUserId != null) {
      parsedUserId = rawUserId.toString();
    }

    final total = (json['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final subtotal = (json['subtotalAmount'] as num?)?.toDouble() ?? total;
    final discount = (json['discountAmount'] as num?)?.toDouble() ?? 0.0;

    List<OrderItem>? parsedItems;
    if (json['items'] is List) {
      parsedItems = (json['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderItem.fromJson(e))
          .toList();
    }

    return Order(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      userId: parsedUserId,
      totalAmount: total,
      subtotalAmount: subtotal,
      discountAmount: discount,
      promoCode: json['promoCode'] as String?,
      status: json['status']?.toString() ?? 'PENDING',
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      deliveryDate: (json['deliveryDate'] as num?)?.toInt() ?? 0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'COD',
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      items: parsedItems,
      customerName: json['customerName'] as String?,
      customerEmail: json['customerEmail'] as String?,
      customerPhone: json['customerPhone'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
      reviewComment: json['reviewComment'] as String?,
      deliveryPartnerId: json['deliveryPartnerId'] as String?,
      deliveryPartnerName: json['deliveryPartnerName'] as String?,
      deliveryPartnerPhone: json['deliveryPartnerPhone'] as String?,
      deliveryOtp: json['deliveryOtp'] as String?,
    );
  }
}

class OrderItem {
  final String cakeName;
  final int quantity;
  final String size;
  final String flavor;
  final String? customMessage;
  final double price;

  OrderItem({
    required this.cakeName,
    required this.quantity,
    required this.size,
    required this.flavor,
    this.customMessage,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      cakeName: json['cakeName']?.toString() ?? 'Artisan Cake',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      size: json['size']?.toString() ?? '1kg',
      flavor: json['flavor']?.toString() ?? 'Classic',
      customMessage: json['customMessage'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
