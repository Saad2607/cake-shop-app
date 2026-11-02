/// Valid order status transitions for admin panel, rider app, and API.
class OrderStatusFlow {
  static const all = [
    'PENDING',
    'CONFIRMED',
    'BAKING',
    'READY',
    'OUT_FOR_DELIVERY',
    'DELIVERED',
    'CANCELLED',
  ];

  static const List<String> pipelineSteps = [
    'PENDING',
    'CONFIRMED',
    'BAKING',
    'READY',
    'OUT_FOR_DELIVERY',
    'DELIVERED',
  ];

  static const Map<String, List<String>> _next = {
    'PENDING': ['CONFIRMED', 'BAKING', 'CANCELLED'],
    'CONFIRMED': ['BAKING', 'CANCELLED'],
    'BAKING': ['READY', 'CANCELLED'],
    'READY': ['OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED'],
    'OUT_FOR_DELIVERY': ['DELIVERED', 'CANCELLED'],
    'DELIVERED': [],
    'CANCELLED': [],
  };

  static List<String> allowedNext(String current) {
    return _next[current] ?? [];
  }

  static bool canTransition(String from, String to) {
    return allowedNext(from).contains(to);
  }

  static bool isTerminal(String status) {
    return status == 'DELIVERED' || status == 'CANCELLED';
  }

  static String label(String status) {
    switch (status) {
      case 'PENDING':
        return 'Placed';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'BAKING':
        return 'Baking';
      case 'READY':
        return 'Ready for Pickup';
      case 'OUT_FOR_DELIVERY':
        return 'Out for Delivery';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  static String hint(String status) {
    switch (status) {
      case 'DELIVERED':
        return 'Order completed and handed over';
      case 'CANCELLED':
        return 'Order cancelled — no further changes';
      case 'READY':
        return 'Cake is boxed & ready for delivery partner pickup';
      case 'OUT_FOR_DELIVERY':
        return 'Delivery partner en route to customer doorstep';
      default:
        return 'Select the next step for this order';
    }
  }
}
