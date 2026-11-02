class CartItem {
  final String id;
  final String cakeId;
  final int quantity;
  final String selectedSize;
  final String selectedFlavor;
  final String? customMessage;
  final double unitPrice;
  String? cakeName;

  CartItem({
    required this.id,
    required this.cakeId,
    required this.quantity,
    required this.selectedSize,
    required this.selectedFlavor,
    this.customMessage,
    required this.unitPrice,
    this.cakeName,
  });

  double get lineTotal => unitPrice * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      cakeId: json['cakeId']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      selectedSize: json['selectedSize'] as String? ?? '1kg',
      selectedFlavor: json['selectedFlavor'] as String? ?? 'Standard',
      customMessage: json['customMessage'] as String?,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      cakeName: json['cakeName'] as String?,
    );
  }
}

class CartResponse {
  final List<CartItem> items;
  final double total;

  CartResponse({required this.items, required this.total});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List?;
    final items = (rawItems ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => CartItem.fromJson(e))
        .toList();
    return CartResponse(
      items: items,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
