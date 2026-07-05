/// Valid order status transitions for admin panel and API.
class OrderStatusFlow {
  static const all = [
    'PENDING',
    'CONFIRMED',
    'BAKING',
    'READY',
    'DELIVERED',
    'CANCELLED',
  ];

  static const Map<String, List<String>> _next = {
    'PENDING': ['CONFIRMED', 'CANCELLED'],
    'CONFIRMED': ['BAKING', 'CANCELLED'],
    'BAKING': ['READY', 'CANCELLED'],
    'READY': ['DELIVERED'],
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
        return 'Pending';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'BAKING':
        return 'Baking';
      case 'READY':
        return 'Ready';
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
        return 'Order completed — no further changes';
      case 'CANCELLED':
        return 'Order cancelled — no further changes';
      case 'READY':
        return 'Mark as delivered when the customer receives the cake';
      default:
        return 'Select the next step for this order';
    }
  }
}
