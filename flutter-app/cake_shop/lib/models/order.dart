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
  }) : subtotalAmount = subtotalAmount ?? totalAmount;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      userId: json['userId'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      subtotalAmount: (json['subtotalAmount'] as num?)?.toDouble() ??
          (json['totalAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      promoCode: json['promoCode'] as String?,
      status: json['status'] as String,
      deliveryAddress: json['deliveryAddress'] as String,
      deliveryDate: json['deliveryDate'] as int,
      paymentMethod: json['paymentMethod'] as String,
      createdAt: json['createdAt'] as int,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      customerName: json['customerName'] as String?,
      customerEmail: json['customerEmail'] as String?,
      customerPhone: json['customerPhone'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
      reviewComment: json['reviewComment'] as String?,
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
      cakeName: json['cakeName'] as String,
      quantity: json['quantity'] as int,
      size: json['size'] as String,
      flavor: json['flavor'] as String,
      customMessage: json['customMessage'] as String?,
      price: (json['price'] as num).toDouble(),
    );
  }
}
