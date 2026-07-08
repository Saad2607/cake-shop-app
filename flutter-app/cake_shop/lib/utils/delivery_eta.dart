/// Delivery time estimates (Blinkit / Swiggy style).
class DeliveryEta {
  static bool get isExpressWindow {
    final now = DateTime.now();
    return now.hour < 14;
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Short chip on home header.
  static String homeChipLabel() {
    if (isExpressWindow) {
      return 'Delivery in 2–4 hours';
    }
    return 'Delivery by tomorrow';
  }

  /// Checkout summary line.
  static String checkoutLabel({DateTime? scheduledDate}) {
    if (scheduledDate != null && !isToday(scheduledDate)) {
      return 'Scheduled delivery on ${_shortDate(scheduledDate)}';
    }
    if (isExpressWindow) {
      return 'Express delivery in 2–4 hours';
    }
    return 'Standard delivery by tomorrow evening';
  }

  static String forOrderStatus(String status) {
    switch (status) {
      case 'PENDING':
        return 'Estimated delivery in 2–4 hours';
      case 'CONFIRMED':
        return 'Confirmed · arrives in 2–3 hours';
      case 'BAKING':
        return 'Baking now · ~1–2 hours left';
      case 'READY':
        return 'Out for delivery · ~30 minutes';
      case 'DELIVERED':
        return 'Delivered successfully';
      case 'CANCELLED':
        return 'Order was cancelled';
      default:
        return 'Tracking your order';
    }
  }

  static String trackerSubtitle(String status) {
    switch (status) {
      case 'PENDING':
        return 'We received your order · ETA 2–4 hrs';
      case 'CONFIRMED':
        return 'Kitchen confirmed · ETA 2–3 hrs';
      case 'BAKING':
        return 'Freshly baking · ETA 1–2 hrs';
      case 'READY':
        return 'Picked up for delivery · ETA 30 min';
      case 'DELIVERED':
        return 'Enjoy your cake!';
      default:
        return '';
    }
  }

  static String _shortDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}
