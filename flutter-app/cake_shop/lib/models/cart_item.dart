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
      id: json['id'] as String,
      cakeId: json['cakeId'] as String,
      quantity: json['quantity'] as int,
      selectedSize: json['selectedSize'] as String,
      selectedFlavor: json['selectedFlavor'] as String,
      customMessage: json['customMessage'] as String?,
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }
}

class CartResponse {
  final List<CartItem> items;
  final double total;

  CartResponse({required this.items, required this.total});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List)
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return CartResponse(
      items: items,
      total: (json['total'] as num).toDouble(),
    );
  }
}
