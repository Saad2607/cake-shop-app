import 'package:flutter/material.dart';
import '../models/order.dart';
import '../providers/cake_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_snackbar.dart';

Future<bool> reorderItems(
  BuildContext context, {
  required Order order,
  required CartProvider cart,
  required CakeProvider cakes,
}) async {
  final items = order.items;
  if (items == null || items.isEmpty) {
    AppSnackBar.error(context, 'No items to reorder');
    return false;
  }

  if (cakes.cakes.isEmpty) {
    await cakes.loadCakes();
  }

  var added = 0;
  for (final item in items) {
    final match = cakes.cakes.where((c) => c.name == item.cakeName).toList();
    if (match.isEmpty) continue;
    final cake = match.first;
    final unitPrice = item.quantity > 0 ? item.price / item.quantity : cake.basePrice;
    await cart.addItem(
      cakeId: cake.id,
      cakeName: cake.name,
      quantity: item.quantity,
      selectedSize: item.size,
      selectedFlavor: item.flavor,
      customMessage: item.customMessage,
      unitPrice: unitPrice,
    );
    added++;
  }

  if (added == 0) {
    if (context.mounted) {
      AppSnackBar.error(context, 'Items are no longer available');
    }
    return false;
  }

  if (context.mounted) {
    AppSnackBar.success(context, 'Added to cart — review and checkout');
  }
  return true;
}
